# IMX585 V4L2 Driver — User Manual

Open-source IMX585 (Sony Starvis2) kernel driver for Raspberry Pi, with **ClearHDR** support.

This package is based on the upstream driver by **will127534**
(<https://github.com/will127534/imx585-v4l2-driver>). It adds a one-step offline installer
(`install.sh`) and a ClearHDR helper (`clearhdr.sh`) on top of the upstream source. The original
driver README is preserved unchanged under
[`imx585-v4l2-driver/README.md`](imx585-v4l2-driver/README.md) for attribution and as the reference
for advanced device-tree options.

- Platform: Raspberry Pi 5 (rp1-cfe + PiSP), kernel 6.12.x, 64-bit (aarch64).
- Prerequisites: `linux-headers`, `dkms`, `gcc`, `make`, `device-tree-compiler` (the installer pulls
  these in automatically).

---

## Table of contents

1. [Install](#1-install)
2. [Device-tree options](#2-device-tree-options)
3. [Verify the camera](#3-verify-the-camera)
4. [ClearHDR overview](#4-clearhdr-overview)
5. [ClearHDR quick start](#5-clearhdr-quick-start)
6. [ClearHDR exposure notes](#6-clearhdr-exposure-notes)
7. [Advanced HDR controls](#7-advanced-hdr-controls)
8. [Output formats](#8-output-formats)
9. [Troubleshooting](#9-troubleshooting)
10. [Credits](#10-credits)

---

## 1. Install

**Recommended — one-step offline installer.** From the package root:

```bash
chmod +x install.sh
sudo ./install.sh
```

`install.sh` builds and installs the driver against your running kernel, with no GitHub access
required on the Pi. In addition to building `imx585.ko`, it does the things a plain build does **not**:

- Installs the matching `linux-headers` (with an `rpi-v8` fallback + build symlink) and build tools.
- **Clears stale shadow modules.** On Raspberry Pi the module loader prefers a compressed
  `updates/dkms/imx585.ko.xz` (or a previous DKMS build) over your freshly built `imx585.ko`, so a
  new driver can silently have no effect. The installer moves any leftover `.ko` / `.ko.xz` aside
  (timestamped backup), removes stale DKMS registrations, then verifies the resolved module path is
  **not** a `.ko.xz`.
- Builds and installs the device-tree overlay (`imx585.dtbo`).
- Backs up `config.txt` and sets `camera_auto_detect=0` + `dtoverlay=imx585` cleanly (existing lines
  are left as-is, never blindly rewritten).

When it finishes, **reboot** and continue with [Verify the camera](#3-verify-the-camera).

> **Alternative (manual / DKMS build).** The upstream `setup.sh` under `imx585-v4l2-driver/` still
> works if you prefer the author's DKMS flow, but it does **not** clear shadow `.ko.xz` modules — if a
> rebuild appears to have no effect, that is usually the cause. See
> [`imx585-v4l2-driver/README.md`](imx585-v4l2-driver/README.md).

---

## 2. Device-tree options

`install.sh` installs the default overlay (`dtoverlay=imx585` — CAM1, color). To change the port,
sensor variant, lane count, or link frequency, edit `/boot/firmware/config.txt` (older Pi OS:
`/boot/config.txt`) and reboot:

```
camera_auto_detect=0
dtoverlay=imx585                 # default: CAM1, color
dtoverlay=imx585,cam0            # use the CAM0 port
dtoverlay=imx585,mono            # monochrome sensor variant
dtoverlay=imx585,ccmp            # enable the 12-bit CCMP ClearHDR path
dtoverlay=imx585,2lane           # 2-lane wiring (default is 4-lane)
dtoverlay=imx585,cam0,mono       # options combine
dtoverlay=imx585,cam0,mono,ccmp  # mono sensor + ClearHDR (recommended, see 2.1)
```

Options combine freely, e.g. `dtoverlay=imx585,mono,cam0,link-frequency=297000000`.

### 2.1 Monochrome sensor + ClearHDR (`ccmp`)

For a **color** sensor ClearHDR works out of the box in 16-bit linear mode. On a **monochrome**
sensor the 16-bit linear ClearHDR output is **not usable — it appears as full-frame snow**; the mono
ClearHDR path that produces a correct image is the **12-bit CCMP** (gradient-compressed) output.

Two things are needed to use it, and the overlay flag is one of them:

1. **Overlay** — add `ccmp` to the mono line so the driver offers the 12-bit CCMP output:

   ```
   camera_auto_detect=0
   dtoverlay=imx585,cam0,mono,ccmp
   ```

2. **Capture in 12-bit** — the application must request the 12-bit mode (otherwise the sensor still
   defaults to 16-bit). The bundled `preview_fullres.sh --hdr` does this automatically; manually it is:

   ```bash
   rpicam-hello -t 0 --mode 3840:2160:12 \
       --tuning-file /usr/local/share/libcamera/ipa/rpi/pisp/imx585_mono.json
   ```

**Confirm ClearHDR is actually engaged** by the frame rate: at 4K all-pixel, ClearHDR runs at
~22 fps (frame length doubled) versus ~30 fps for normal SDR. Same-looking-but-30 fps means SDR;
~22 fps means ClearHDR is active. `ccmp` is harmless for a color sensor (it only adds the 12-bit
option; color ClearHDR still defaults to 16-bit linear).

For the full explanation of each option — **lane count**, the **link-frequency table** (mbps/lane vs
max framerate), **sync modes** (internal-leader / internal-follower / external), and the always-on
debug flag — see the upstream author's guide:
[`imx585-v4l2-driver/README.md`](imx585-v4l2-driver/README.md).

---

## 3. Verify the camera

After rebooting:

```bash
# Confirm the NEW driver loaded (must NOT resolve to a .ko.xz)
modinfo -F filename imx585
dmesg | grep imx585

# List cameras
rpicam-hello --list-cameras

# Live preview (color)
rpicam-hello -t 0

# Live preview (mono sensor)
rpicam-hello -t 0 --tuning-file /usr/local/share/libcamera/ipa/rpi/pisp/imx585_mono.json
```

> This package installs the **kernel driver** only. If `rpicam-hello` cannot detect the camera after a
> clean install + reboot, libcamera support (tuning / IPA) must be installed separately.

---

## 4. ClearHDR overview

**ClearHDR** is the IMX585 built-in **single-frame wide dynamic range** feature, based on
**Dual Conversion Gain (DCG)**: a single exposure is read out twice — once at **High Gain (HG)** and
once at **Low Gain (LG)** — and the two are combined inside the sensor into one wide-dynamic image.

Compared with conventional two-frame alternating (DOL) HDR, ClearHDR offers:

- **Single-exposure combination** — HG and LG come from the same exposure, so there are **no motion
  artifacts**. Suitable for scenes with movement.
- **Significantly wider dynamic range** — highlights preserved by LG, shadows lifted by HG (with an
  extra +12 dB by default).
- **Two output bit depths**:
  - **16-bit linear** (`SRGGB16` / mono `Y16`): uncompressed, smoothest gradation, but ISP statistics
    are not valid at 16-bit, so **manual exposure is required**.
  - **12-bit gradient-compressed** (`SRGGB12` / `Y12`, CCMP): the wide range is compressed back into
    12-bit, compatible with the normal ISP/AGC (auto-exposure) path.

When ClearHDR is enabled the driver automatically adjusts these operating points (vs plain SDR):

| Item | Normal SDR | ClearHDR |
|---|---|---|
| Sensor mode | Normal | Clear HDR |
| Max analogue gain | 240 | **80** |
| Max exposure (lines) | set by VMAX | **~4484** (varies by mode) |
| VMAX (frame length) | base | **×2** (frame rate halved) |
| pixel_rate | base | **halved** |
| Min SHR | 8 | **16** |
| Frame rate (4K all-pixel) | — | ~22 fps |

> Frame rate and exposure limits vary with the selected resolution / bit depth. Treat the live
> `exposure` and `analogue_gain` ranges from `v4l2-ctl --list-ctrls` as the source of truth.

---

## 5. ClearHDR quick start

### 5.1 Helper script (shortcut)

A helper script `clearhdr.sh` is included at the package root. It auto-detects the sensor subdevice
and wraps the manual commands below:

```bash
./clearhdr.sh on        # enable ClearHDR
./clearhdr.sh off       # back to normal SDR
./clearhdr.sh status    # current state + exposure/gain ranges
./clearhdr.sh preview   # enable ClearHDR and preview with the recommended baseline
```

For a mono camera, pass the mono tuning file to `preview`:

```bash
TUNING=/usr/local/share/libcamera/ipa/rpi/pisp/imx585_mono.json ./clearhdr.sh preview
```

The manual steps below are the equivalent without the script.

**Full-resolution preview helper (`preview_fullres.sh`).** A second helper, `preview_fullres.sh`, is
included at the package root for a 4K all-pixel live preview. It auto-detects a mono sensor (and picks
`imx585_mono.json` automatically), and with `--hdr` it enables ClearHDR **and forces the 12-bit CCMP
mode** — the correct mono ClearHDR path (see [Section 2.1](#21-monochrome-sensor--clearhdr-ccmp)).

```bash
./preview_fullres.sh              # full-res SDR preview, auto AE/AWB
./preview_fullres.sh --hdr        # enable ClearHDR (12-bit CCMP) and preview
./preview_fullres.sh --mono       # force the mono tuning file
./preview_fullres.sh --hdr --manual   # ClearHDR with a known-good manual exposure
```

Requires the `ccmp` overlay flag for the mono HDR path (Section 2.1). Extra `rpicam-hello` arguments
pass straight through, e.g. `./preview_fullres.sh --hdr -t 10000`.

### 5.2 Enable / disable ClearHDR

ClearHDR is toggled by the V4L2 control **`wide_dynamic_range`** (boolean) on the **sensor
subdevice**. No reboot and no device-tree change are needed.

Locate the IMX585 subdevice node first (usually `/dev/v4l-subdev2`, confirm on your system):

```bash
# Find the subdevice that exposes wide_dynamic_range
for s in /dev/v4l-subdev*; do
  v4l2-ctl -d "$s" --list-ctrls 2>/dev/null | grep -q wide_dynamic_range && echo "$s"
done
```

Enable / disable:

```bash
v4l2-ctl -d /dev/v4l-subdev2 --set-ctrl wide_dynamic_range=1   # enable ClearHDR
v4l2-ctl -d /dev/v4l-subdev2 --set-ctrl wide_dynamic_range=0   # back to normal SDR
v4l2-ctl -d /dev/v4l-subdev2 --get-ctrl wide_dynamic_range     # check state
```

### 5.3 Preview / capture

With ClearHDR enabled, libcamera selects the 16-bit mode. The log shows:

```
Selected sensor format: 3840x2200-SRGGB16_1X16/RAW
WARN ... The sensor is configured for a 16-bit output, statistics will
     not be correct. You must use manual camera settings.
```

This 16-bit statistics warning is expected; see the next section.

---

## 6. ClearHDR exposure notes (important)

**In 16-bit ClearHDR, ISP auto-exposure (AGC) is not reliable — you must set exposure manually.**
The 16-bit RAW statistics are not correctly collected by the ISP, so AGC misjudges and drives the
image dark.

Also note that **ClearHDR has a lower maximum exposure (~4484 lines)**. If the microsecond value
passed to `--shutter` converts to a line count **above that limit**, SHR is computed out of range and
the result is a **fully black frame** — this is an out-of-range exposure, not a fault.

Recommended: **manual exposure + manual gain, starting from a short shutter**.

```bash
# Recommended baseline: short shutter + high gain + AWB
rpicam-hello -t 0 --gain 80 --shutter 200 --awb auto

# Capture a 16-bit RAW (DNG)
rpicam-still -t 1000 --gain 8 --shutter 2000 -r -o hdr16.dng
```

Rule of thumb: **if the image goes black, suspect the shutter is too large first** — reduce
`--shutter` (e.g. 200–2000 us) to recover.

> For convenient auto-exposure, use the **12-bit CCMP** output (`SRGGB12` / `Y12`) instead. It
> compresses the wide range back into 12-bit, so statistics are valid and AGC works; the trade-off is
> that highlight gradation is not as smooth as 16-bit.

---

## 7. Advanced HDR controls

The driver exposes a set of ClearHDR-specific controls for tuning the HG/LG combination and the
compression curve. The defaults already produce a usable image; adjust only when tuning.

Live ranges (from `v4l2-ctl -d /dev/v4l-subdev2 --list-ctrls-menus`):

| Control | Type | Range | Default | Purpose |
|---|---|---|---|---|
| `wide_dynamic_range` | bool | 0 / 1 | 0 | ClearHDR master switch |
| `hdr_gain_adder_db` | menu | 0–5 | 2 (+12 dB) | Extra HG gain over LG |
| `hdr_data_blending_mode` | menu | 0–7 | 0 | HG/LG blend ratio |
| `hdr_data_selection_threshold` | u16 ×2 | 0–4095 | 0 | HG/LG selection threshold (HG saturation cutoff) |
| `hdr_gradient_compression_thresh` | u32 ×2 | 0–131071 | 0 | 16-bit gradient-compression threshold (12-bit CCMP path) |
| `exposure` | int | 2–4484 | 19 | Exposure in lines (ClearHDR range) |
| `analogue_gain` | int | 0–80 | 0 | Analogue gain (ClearHDR limit) |

**`hdr_gain_adder_db` menu values:**

| Value | Gain | Value | Gain |
|---|---|---|---|
| 0 | +0 dB | 3 | +18 dB |
| 1 | +6 dB | 4 | +24 dB |
| 2 | +12 dB (default) | 5 | +29.1 dB |

**`hdr_data_blending_mode` menu values:**

| Value | Meaning | Value | Meaning |
|---|---|---|---|
| 0 | HG 1/2, LG 1/2 | 4 | HG 1/2, LG 1/2 (alt) |
| 1 | HG 3/4, LG 1/4 | 5 | HG 1/16, LG 15/16 |
| 2 | HG 7/8, LG 1/8 | 6 | HG 1/8, LG 7/8 |
| 3 | HG 15/16, LG 1/16 | 7 | HG 1/4, LG 3/4 |

Example — set the extra HG gain to +18 dB (brighter shadows):

```bash
v4l2-ctl -d /dev/v4l-subdev2 --set-ctrl hdr_gain_adder_db=3   # 3 -> +18 dB
```

---

## 8. Output formats

| Output | Media-bus code | Characteristics | Statistics / AGC | Use case |
|---|---|---|---|---|
| 16-bit linear | `SRGGB16` / `Y16` | Smoothest gradation, uncompressed | Not valid, manual exposure | Best wide dynamic range with manual control |
| 12-bit CCMP | `SRGGB12` / `Y12` | Wide range compressed to 12-bit | Valid, AGC works | Plug-and-play / auto-exposure |

- In 16-bit ClearHDR the sensor prepends **20 OB rows** (`3840x2200 = 2180 active + 20 OB`). The PiSP
  centered crop skips these rows automatically; no user action needed.
- A mono camera must use `imx585_mono.json`; otherwise the color tuning makes the image
  **color-cast / greenish** — a tuning mismatch, not a sensor issue.

---

## 9. Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| New driver seems to have no effect after rebuild | A leftover `.ko.xz` shadow module loads instead | Use `./install.sh` (it clears shadows), or check `modinfo -F filename imx585` is not a `.ko.xz` |
| Fully black after enabling ClearHDR | `--shutter` exceeds the ClearHDR exposure limit, SHR out of range | Reduce `--shutter` (e.g. 200–2000 us) |
| Preview starts fine, then goes dark | 16-bit statistics invalid, AGC drives exposure dark | Use **manual exposure** `--gain` / `--shutter` |
| Color cast / greenish image | Mono camera using color tuning | Add `--tuning-file .../imx585_mono.json` |
| `wide_dynamic_range` toggle has no effect | Wrong subdevice node | Use `./clearhdr.sh status`, or the loop in Section 5.2, to find the correct `/dev/v4l-subdevN` |
| Gain / exposure cannot go higher | ClearHDR has lower limits (gain ≤ 80) | Expected limit, see Section 4 |

---

## 10. Credits

- Upstream driver: [will127534/imx585-v4l2-driver](https://github.com/will127534/imx585-v4l2-driver)
  — original source, device-tree options, and sync-mode guide.
- Additional register info: Soho-enterprise.
- DKMS install script adapted from the renetec-io CM4 panel project.

The original upstream README is included verbatim at
[`imx585-v4l2-driver/README.md`](imx585-v4l2-driver/README.md).
