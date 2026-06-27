# CAM-IMX585-Mono/CAM-IMX585-Color MIPI Camera Module

![CAM-IMX585](imx585.png)

## 1. Product Overview

The **CAM-IMX585-Mono** and **CAM-IMX585-Color** are high-performance CMOS image sensors designed for demanding imaging applications in embedded systems. The **Mono** variant features a monochrome sensor for enhanced low-light sensitivity, while the **Color** variant provides full RGB color imaging. Both feature an advanced Starvis 2 back-illuminated pixel structure, delivering 8.3MP resolution with exceptional low-light performance, high dynamic range, and precise image quality across diverse lighting conditions.

With native 3840×2160 (4K UHD) resolution and support for 10/12/16-bit RAW output, the CAM-IMX585-Mono/Color enables professional-grade imaging for surveillance, industrial inspection, machine vision, and embedded vision applications. The sensor's MIPI CSI-2 4-lane interface ensures reliable high-speed data transmission to host processors like Raspberry Pi 5 and NVIDIA Jetson. The on-board **FT24C02A EEPROM** (256 bytes) supports camera calibration data storage and I2C-based read/write operations.

*Note: While the sensor supports 10/12/16-bit RAW output, the current driver configuration operates in 12-bit RAW (R12_CSI2P) mode on Raspberry Pi 5.*

### 1.1 Key Features

- **8.3MP 4K resolution** with Starvis 2 technology
- **Monochrome (Mono)** sensor for enhanced low-light sensitivity / **Color (RGB)** sensor for full-spectrum imaging
- **MIPI CSI-2 4-lane** high-speed interface
- **10/12/16-bit RAW output capability** (currently 12-bit)
- **Excellent low-light performance** with back-illuminated pixels
- **On-board EEPROM** (FT24C02A, 256 bytes) for calibration data storage
- **I2C interface** for EEPROM and sensor register access
- **4K ClearHDR 12-bit** — compressed HDR output with 4× contrast improvement *(InnoMaker Unique Driver only)*
- **4K ClearHDR 16-bit** — uncompressed gradation HDR for finest highlight roll-off *(InnoMaker Unique Driver only)*
- **Compatible with Raspberry Pi and NVIDIA Jetson Orin Nano**

### 1.2 Industry Applications

- Security & Surveillance (24/7 monitoring)
- Industrial & Machine Vision (AOI, robotics)
- Broadcast & ProAV (live streaming, drones)
- Scientific & Medical (microscopy, diagnostics)
- Automotive (ADAS, surround-view cameras)

---

## 2. Hardware Specifications

### 2.1 Sensor Specifications

| Parameter | Specification |
| :--- | :--- |
| **Product Model** | CAM-IMX585-Mono / CAM-IMX585-Color |
| **Sensor Model** | Sony IMX585 (Monochrome) / Sony IMX585 (Color) |
| **Sensor Type** | CMOS (Mono) / CMOS (Color)
| **Pixel Technology** | Starvis 2 |
| **Effective Resolution** | 8.3MP |
| **Optical Format** | 1/1.2" |
| **Pixel Size** | 2.9μm × 2.9μm |
| **Active Pixels** | 3840 (H) × 2160 (V) |
| **Max Resolution** | 3840×2160 (4K UHD) |
| **Supported RAW Output** | 10/12/16-bit |

### 2.2 Video Format & Resolution/Frame Rate

| Resolution | Frame Rate | Pixel Format | Notes |
| :--- | :--- | :--- | :--- |
| 1928×1090 | 60.00 fps | R12_CSI2P | 1080p cropped, standard mode |
| 3856×2180 | 30.00 fps | R12_CSI2P | 4K native, standard mode |
| 3856×2180 | 30.00 fps | R12_CSI2P | 4K ClearHDR 12-bit |
| 3856×2180 | 30.00 fps | R16 | 4K ClearHDR 16-bit |

> **Note:** ClearHDR 12-bit (compressed HDR, 4× contrast improvement) and ClearHDR 16-bit (higher bit depth, smoother gradation) modes are **only available with the [InnoMaker Unique Driver](innomaker_unique_driver/raspberry_pi/)**. The open-source driver supports R12_CSI2P only. ClearHDR is enabled via `v4l2-ctl -d /dev/v4l-subdev2 --set-ctrl wide_dynamic_range=1`; 16-bit mode additionally requires `--mode 3856:2180:16:U` and manual exposure (PiSP does not support 16-bit statistics).

### 2.3 Interface & Physical Specifications

| Parameter | Specification |
| :--- | :--- |
| **Interface Type** | MIPI CSI-2 |
| **Data Lanes** | 4-lane |
| **Data Rate** | 1.5 Gbps per lane |
| **Connector** | 22-pin FPC |
| **Dimensions** | 38mm × 38mm |
| **Lens Mount** | CS-mount / M12 |

---

## 3. Software Installation

This repository provides two driver options for the IMX585 sensor on Raspberry Pi:

- **3.1 IMX585 Opensource Driver** — standard open-source driver with R12_CSI2P support, suitable for most users.
- **3.2 InnoMaker Unique Driver** — InnoMaker's independently released driver with additional ClearHDR 12-bit and 16-bit support.

---

### 3.1 IMX585 Opensource Driver

The open-source driver supports standard R12_CSI2P output and is provided in two installation options.

#### Option A: Pre-compiled Driver Installation (Recommended)

> ⚠️ **Important Notice**: Pre-compiled driver packages are built for **specific OS versions and kernel versions**. Before installation, please verify that your system's OS version and kernel version match exactly. If they do not match, use **Option B (source compilation)** instead.

The `precompiler-driver/` directory contains pre-compiled kernel modules and IPA files for tested OS versions. Each package is named with the target OS, platform, and kernel version for easy identification.

**Supported Versions:**

| Package | OS | Platform | Kernel |
| :--- | :--- | :--- | :--- |
| `imx585_trixie_pi5_k6.12.75+rpt-rpi-2712_20260420-114959.tar.gz` | Raspberry Pi OS Trixie | Pi 5 (2712) | 6.12.75+rpt-rpi-2712 |

**Check your system version before installation:**
```bash
# Check OS version
cat /etc/os-release

# Check kernel version
uname -r
```

**Installation:**
```bash
# Extract the matching package (replace filename with your version)
tar -xzf precompiler-driver/imx585_trixie_pi5_k6.12.75+rpt-rpi-2712_20260420-114959.tar.gz

# Run the installation script
chmod +x install.sh
sudo ./install.sh
```

> 📝 **Note**: More pre-compiled packages for additional OS versions will be added as testing is completed. If your OS version is not listed, please use Option B (source compilation).

#### Option B: Offline Driver Compilation (Source)

> Use this option if your OS/kernel version is not listed in the pre-compiled packages above, or if you require a custom build.

**Step 1: Offline Driver Compilation**

**Package**: `pkg1-imx585-driver-6.12y-offline.tar.gz`

**Contents**:
- `imx585-v4l2-driver/` - Kernel driver source code
- `install.sh` - Automated driver installation script

```bash
$ tar -xzf pkg1-imx585-driver-6.12y-offline.tar.gz
$ cd pkg1-imx585-driver
$ chmod +x install.sh
$ sudo ./install.sh
```

**Step 2: Offline libcamera & rpicam-apps Compilation**

**Package**: `pkg2-rpicam-libcamera-offline.tar.gz`

**Contents**:
- `libcamera-imx585/` - libcamera source with IMX585 IPA support
- `rpicam-apps-imx585/` - rpicam-apps source
- `build.sh` - Automated build and installation script

```bash
$ tar -xzf pkg2-rpicam-libcamera-offline.tar.gz
$ cd pkg2-rpicam-offline
$ chmod +x build.sh
$ sudo ./build.sh           # Full mode with Qt support
$ sudo ./build.sh --lite    # Lite mode (minimal dependencies)
```

**Build Time**: ~30-40 minutes (full mode) or ~15-20 minutes (lite mode)

---

### 3.2 InnoMaker Unique Driver

The InnoMaker Unique Driver is independently developed and released by InnoMaker. It extends the open-source driver with **ClearHDR 12-bit and 16-bit output modes**, which are not available in the standard open-source version.

**Feature comparison:**

| Driver | R12_CSI2P (standard 12-bit) | ClearHDR 12-bit (compressed HDR) | ClearHDR 16-bit (high bit depth) |
| :--- | :---: | :---: | :---: |
| Opensource Driver | ✅ | ❌ | ❌ |
| InnoMaker Unique Driver | ✅ | ✅ | ✅ |

Driver packages are located in [`innomaker_unique_driver/`](innomaker_unique_driver/).

---

#### 3.2.1 Jetson Orin Nano

Prebuilt binary driver for **Jetson Orin Nano** (L4T R36.4.4). Supports **Normal**, **HCG**, and **ClearHDR 12-bit / 16-bit** modes.

> **Version:** v2.0 (stable) | **Build date:** 2026-06-27 | **Validated link speed:** 1188 Mbps/lane (2-lane MIPI CSI-2)

Two packages are provided — choose the one matching your kernel version:

| Package | Kernel | Path |
| :--- | :--- | :--- |
| `imx585_tegra_binary_1188_working_5.15.148_20260627_v2_0.tar.gz` | `5.15.148-tegra` (L4T R36.4.4) | `innomaker_unique_driver/jetson-orin-nano-driver/5.15.148/` |
| `imx585_tegra_binary_1188_working_5.15.185_20260627_v2_0.tar.gz` | `5.15.185-tegra` | `innomaker_unique_driver/jetson-orin-nano-driver/5.15.185/` |

Check your kernel version with `uname -r` before selecting a package.

##### Package Contents

| File | Description |
| :--- | :--- |
| `binary/imx585.ko` | Prebuilt kernel module |
| `overlays/tegra234-p3767-camera-p3768-imx585-cam0.dtbo` | Device tree overlay for CAM0 ⭐ New in v2.0 |
| `overlays/tegra234-p3767-camera-p3768-imx585-cam1.dtbo` | Device tree overlay for CAM1 |
| `overlays/tegra234-p3767-camera-p3768-imx585-dual.dtbo` | Device tree overlay for dual CAM0+CAM1 ⭐ New in v2.0 |
| `isp/camera_overrides.imx585_starter.isp` | Validated starter ISP tuning profile |
| `install_binary.sh` | One-step installer (also installs `imx585-reload.service`) |
| `imx585-reload.service` | Boot initialization service (loads Normal mode at boot) |
| `scripts/switch_mode.sh` | One-command mode switcher (Normal / HCG / HDR12 / HDR16) |
| `scripts/preview_argus.sh` | Live preview — color sensor |
| `scripts/preview_argus_mono.sh` | Live preview — Mono sensor (Argus ISP, recommended for clean image) |
| `scripts/preview_mono.sh` | Live preview — Mono sensor via V4L2 full-res (4K, auto-restores on exit) |
| `scripts/preview_argus_hdr.sh` | Live ClearHDR preview — color sensor |
| `scripts/preview_argus_mono_hdr.sh` | Live ClearHDR preview — Mono sensor (locked AE + GRAY8) |
| `scripts/capture_argus_image.sh` | Capture JPEG image via Argus |
| `scripts/capture_argus_video.sh` | Record video via Argus |
| `scripts/capture_v4l2_image.sh` | Capture RAW image via V4L2 |
| `scripts/capture_mono_image.sh` | Capture RAW image for Mono sensor |
| `scripts/imx585_raw16_to_pnm.py` | RAW16 to PNM conversion tool (required by capture scripts) |
| `develop/` | Diagnostic helpers — not for end users |

##### Operating Modes

The v2.0 driver supports four operating modes. **Normal mode is the default after installation.**

| Mode | Switch Command | Output | Argus 4K | Argus 1080p | V4L2 RAW | Default |
| :--- | :--- | :--- | :---: | :---: | :---: | :---: |
| **Normal (LCG)** | `switch_mode.sh normal` | RAW12 linear | ✅ | ✅ | ✅ | ⭐ Yes |
| **HCG** | `switch_mode.sh hcg` | RAW12 linear (high conversion gain) | ✅ | ✅ | ✅ | ❌ |
| ClearHDR 12-bit | `switch_mode.sh hdr12` | RAW12 compressed HDR | ✅ (locked exp.) | ❌ | ⚠️ | ❌ |
| ClearHDR 16-bit | `switch_mode.sh hdr16` | RG12 uncompressed gradation HDR | ✅ (locked exp.) | ❌ | ⚠️ | ❌ |

> **Note:** HCG mode provides low-noise / low-light performance with linear output. ClearHDR modes are opt-in — Argus AE misreads HDR luminance and drives exposure to all-black without locked exposure; capture/preview scripts auto-pin `exposuretimerange` and `gainrange`. Use 4K for HDR; binned 1080p HDR is currently unusable.

##### Installation

**Step 1: Extract and install**

```bash
# Example for kernel 5.15.148-tegra:
tar -xzf imx585_tegra_binary_1188_working_5.15.148_20260627_v2_0.tar.gz
cd imx585_tegra_binary_1188_working_5.15.148_20260627_v2_0
sudo ./install_binary.sh
```

The installer will:
- Install `imx585.ko` to `/lib/modules/<kernel-version>/`
- Copy all three DTBO files to `/boot` and auto-stamp each overlay's CSI header name
- Install the starter ISP profile to `/var/nvidia/nvcam/settings/camera_overrides.isp`
- Configure module autoload
- **Install and enable `imx585-reload.service`** (loads Normal mode at every boot)
- Restart `nvargus-daemon`

> The installer **never edits `/boot/extlinux/extlinux.conf`** directly.

**Step 2: Configure CSI overlay**

Activate one overlay with NVIDIA jetson-io:

```bash
sudo python3 /opt/nvidia/jetson-io/config-by-hardware.py -l
sudo python3 /opt/nvidia/jetson-io/config-by-hardware.py -n '2=Camera IMX585 CAM0'
```

Available overlays:
- `Camera IMX585 CAM0` — single camera on CAM0 (recommended)
- `Camera IMX585 CAM1` — single camera on CAM1
- `Dual Camera IMX585 CAM0 CAM1` — dual cameras

**Step 3: Reboot**

```bash
sudo reboot
```

##### Verification

```bash
# Check kernel module
lsmod | grep imx585

# Check video device
v4l2-ctl --list-devices

# Check current mode
./scripts/switch_mode.sh status
# Expected: Current mode: Normal (hdr_mode=0)
```

Expected output from `v4l2-ctl --list-devices`:
```
NVIDIA Tegra Video Input Device (platform:tegra-camrtc-ca):
    /dev/media0
vi-output, imx585 9-001a (platform:tegra-capture-vi:2):
    /dev/video0
```

##### Usage

**Switching Modes:**

```bash
./scripts/switch_mode.sh status          # Show current mode
sudo ./scripts/switch_mode.sh normal     # Normal RAW12 linear LCG (default)
sudo ./scripts/switch_mode.sh hcg        # HCG linear (low-noise / low-light)
sudo ./scripts/switch_mode.sh hdr12      # ClearHDR 12-bit
sudo ./scripts/switch_mode.sh hdr16      # ClearHDR 16-bit
```

**Live Preview:**

```bash
cd scripts

# Normal mode — color sensor
./preview_argus.sh 1080p
./preview_argus.sh 4k

# Normal mode — Mono sensor (Argus ISP, recommended for clean image)
./preview_argus_mono.sh 1080p
./preview_argus_mono.sh 4k

# Normal mode — Mono sensor via V4L2 full-res (sharper, but shows sensor row FPN)
DISPLAY=:0 ./preview_mono.sh 4k

# ClearHDR preview — color sensor (auto-pins locked exposure)
./preview_argus_hdr.sh 4k

# ClearHDR preview — Mono sensor (locked AE + GRAY8 round-trip)
./preview_argus_mono_hdr.sh 4k
```

**Capture Images:**

```bash
# Normal mode — JPEG via Argus
./capture_argus_image.sh 1080p /tmp/imx585_photo.jpg
./capture_argus_image.sh 4k /tmp/imx585_4k.jpg

# ClearHDR mode — switch first, then capture at 4K
sudo ./scripts/switch_mode.sh hdr12
./capture_argus_image.sh 4k /tmp/hdr12.jpg

# Override locked exposure if needed
EXPOSURE_NS=20000000 GAIN=10 ./capture_argus_image.sh 4k /tmp/hdr_custom.jpg

# RAW via V4L2 (Normal mode only)
./capture_v4l2_image.sh 1080p /tmp/imx585_raw.png
```

**Record Video:**

```bash
./capture_argus_video.sh 1080p /tmp/imx585_video.mp4 30
./capture_argus_video.sh 4k /tmp/imx585_4k.mp4 10
```

**Make ClearHDR the boot default (optional):**

```bash
sudo systemctl edit imx585-reload.service
```

Add the following (for ClearHDR 12-bit):
```ini
[Service]
ExecStart=
ExecStart=/sbin/modprobe imx585 hdr_mode=1 hdr_bit_depth=12
```

To revert to Normal default:
```bash
sudo systemctl revert imx585-reload.service
sudo systemctl daemon-reload
```

##### Technical Specifications

| Parameter | Value |
| :--- | :--- |
| Sensor | Sony IMX585 (Color RGGB Bayer / Mono) |
| Interface | 2-lane MIPI CSI-2 |
| Validated data rate | 1188 Mbps/lane |
| Pixel format | RG12 (12-bit Bayer) |
| 4K resolution | 3856×2180 (sensor) / 3840×2160 (output) |
| 1080p resolution | 1928×1090 (sensor) / 1920×1080 (output) |
| Max frame rate @ 4K | 20 fps (single camera, 2-lane @ 1188 Mbps) |
| Max frame rate @ 1080p | 40 fps (2×2 binned) |
| Kernel ABI | 5.15.148-tegra (L4T R36.4.4) / 5.15.185-tegra |
| Operating modes | Normal (LCG) / HCG / ClearHDR 12-bit / ClearHDR 16-bit |

##### Troubleshooting

| Symptom | Solution |
| :--- | :--- |
| `/dev/video0` missing after reboot | Run `sudo modprobe imx585`; check `sudo dmesg \| grep -i imx585` |
| Corrupted/garbled preview | Reload: `sudo systemctl stop nvargus-daemon && sudo rmmod imx585 && sudo modprobe imx585 && sudo systemctl start nvargus-daemon` |
| `Connection refused` from nvargus | Run `sudo systemctl restart nvargus-daemon` |
| Camera not detected (module loads OK) | Check extlinux.conf: `grep OVERLAYS /boot/extlinux/extlinux.conf`; re-run `configure_extlinux_overlay.sh` and reboot |
| ClearHDR image all-black | Argus AE issue — use `switch_mode.sh hdr12` then capture with locked exposure via `capture_argus_image.sh 4k` |
| HDR at 1080p all-black | Known limitation — use 4K resolution for ClearHDR modes |
| Mono ClearHDR has colour cast or pink tint | Use `preview_argus_mono_hdr.sh` instead of `preview_argus_hdr.sh`; it applies GRAY8 round-trip to neutralize Argus AWB/CCM |
| `capture_mono_image.sh` or `capture_v4l2_image.sh` fails | Ensure `scripts/imx585_raw16_to_pnm.py` is present (bundled since v1.5) |

---

#### 3.2.2 Raspberry Pi

Prebuilt binary driver for **Raspberry Pi 5** with ClearHDR support.

> **Package version**: v1.2.0 (2026-06-27) — `imx585-clearhdr-binary-v1.2.0.tar.gz`  
> Driver packages are located in [`innomaker_unique_driver/raspberry_pi/`](innomaker_unique_driver/raspberry_pi/).

##### Supported Versions

| Package | Platform | Kernel | Notes |
| :--- | :--- | :--- | :--- |
| `imx585-clearhdr-binary-v1.2.0.tar.gz` | Raspberry Pi 5 | 6.12.47+rpt-rpi-2712 | Recommended |

> ⚠️ **Important**: The binary package requires an **exact kernel version match**. Check your kernel with `uname -r` before installation.

##### Installation

```bash
tar -xzf imx585-clearhdr-binary-v1.2.0.tar.gz
cd imx585-clearhdr-binary-v1.2.0/driver-binary
chmod +x install.sh
./install.sh
sudo reboot
```

> The installer detects `config.txt`, reports whether the `dtoverlay=imx585` line is present, and can append it automatically (with backup).

##### Camera Configuration

Edit `/boot/firmware/config.txt`:

```ini
# Color camera on CAM0
dtoverlay=imx585,cam0

# Mono camera on CAM0
dtoverlay=imx585,cam0,mono
```

Then reboot:
```bash
sudo reboot
```

##### HDR Usage

ClearHDR mode is controlled via `v4l2-ctl` before launching rpicam. The sensor subdevice is typically `/dev/v4l-subdev2` (verify with `v4l2-ctl --list-devices`).

**Mode 1: Normal SDR / LCG (default)**

Standard 12-bit single gain mode, best for well-lit scenes.

```bash
# Ensure ClearHDR is off and HCG is off (default after boot)
v4l2-ctl -d /dev/v4l-subdev2 --set-ctrl wide_dynamic_range=0,hcg_enable=0

# Preview — Mono camera
rpicam-hello -t 0 --tuning-file /usr/local/share/libcamera/ipa/rpi/pisp/imx585_mono.json

# Preview — Color camera
rpicam-hello -t 0 --tuning-file /usr/local/share/libcamera/ipa/rpi/pisp/imx585.json
```

**Mode 2: HCG SDR (low-light / high conversion gain)**

Linear 12-bit output with high conversion gain for low-noise / low-light scenes.

```bash
v4l2-ctl -d /dev/v4l-subdev2 --set-ctrl wide_dynamic_range=0,hcg_enable=1

# Preview — Mono camera
rpicam-hello -t 0 --tuning-file /usr/local/share/libcamera/ipa/rpi/pisp/imx585_mono.json

# Preview — Color camera
rpicam-hello -t 0 --tuning-file /usr/local/share/libcamera/ipa/rpi/pisp/imx585.json
```

**Mode 3: ClearHDR 12-bit (real-time HDR)**

Sensor-internal HCG/LCG fusion with gradation compression. Supports real-time preview, still capture, and video recording.

```bash
# Enable ClearHDR
v4l2-ctl -d /dev/v4l-subdev2 --set-ctrl wide_dynamic_range=1

# Preview — Mono camera (use _hdr tuning file with --hdr flag)
rpicam-hello -t 0 --hdr --tuning-file /usr/local/share/libcamera/ipa/rpi/pisp/imx585_mono_hdr.json

# Preview — Color camera
rpicam-hello -t 0 --hdr --tuning-file /usr/local/share/libcamera/ipa/rpi/pisp/imx585_hdr.json

# Still capture — Mono camera
rpicam-still --hdr --tuning-file /usr/local/share/libcamera/ipa/rpi/pisp/imx585_mono_hdr.json \
  -o hdr12.jpg -t 2000

# Video recording — Mono camera
rpicam-vid --hdr --tuning-file /usr/local/share/libcamera/ipa/rpi/pisp/imx585_mono_hdr.json \
  -o hdr_video.h264 -t 10000
```

> **Note**: Always use `--hdr` together with the `_hdr.json` tuning file for ClearHDR 12-bit. Without `--hdr`, the ISP does not apply HDR tone mapping and the image will appear flat/washed out.

**Mode 4: ClearHDR 16-bit (maximum dynamic range)**

Full 16-bit linear HDR output. Requires manual exposure and post-processing merge.

```bash
# Enable ClearHDR
v4l2-ctl -d /dev/v4l-subdev2 --set-ctrl wide_dynamic_range=1

# Force sensor to 16-bit output — Mono camera
media-ctl -d /dev/media0 --set-v4l2 '"imx585 10-001a":0[fmt:Y16_1X16/3856x2180]'

# Capture 16-bit RAW (manual exposure required)
rpicam-still --tuning-file /usr/local/share/libcamera/ipa/rpi/pisp/imx585_mono.json \
  --raw -o raw16.jpg --shutter 20000 --gain 4 --awbgains 1,1 --immediate
```

For color cameras, replace `Y16_1X16` with `SRGGB16_1X16` and use `imx585.json`.

> **Note**: 16-bit mode requires manual exposure (`--shutter`, `--gain`) as PiSP statistics do not support 16-bit data.

**Return to Normal SDR:**

```bash
v4l2-ctl -d /dev/v4l-subdev2 --set-ctrl wide_dynamic_range=0
```

> ClearHDR mode persists until changed or reboot. Normal SDR is restored automatically after reboot.

##### Tuning Files

| File | Usage |
| :--- | :--- |
| `imx585.json` | Color camera, Normal SDR |
| `imx585_mono.json` | Mono camera, Normal SDR |
| `imx585_hdr.json` | Color camera, ClearHDR 12-bit |
| `imx585_mono_hdr.json` | Mono camera, ClearHDR 12-bit |

##### 16-bit Merge Tool

Process 16-bit RAW DNG files captured in Mode 3 using the included `tools/clearhdr_merge.py`:

```bash
# Auto-detect gain ratio
python3 clearhdr_merge.py raw16.dng -o merged.tiff

# Generate 8-bit preview
python3 clearhdr_merge.py raw16.dng -o merged.tiff --preview
```

For full usage details, see [`innomaker_unique_driver/raspberry_pi/`](innomaker_unique_driver/raspberry_pi/) — the package includes `README.md` and `USAGE.md`.

---

### 3.3 Manual Configuration (Both Options)

Edit your `/boot/firmware/config.txt` (Pi 5) or `/boot/config.txt` (Pi 4) and add one of the following configurations:

**Default (CAM1 port, Color mode)** - for CAM-IMX585-Color:
```ini
camera_auto_detect=0
dtoverlay=imx585
```

**Default (CAM1 port, Monochrome mode)** - for CAM-IMX585-Mono:
```ini
camera_auto_detect=0
dtoverlay=imx585,mono
```

**Use CAM0 port (Color)**:
```ini
dtoverlay=imx585,cam0
```

**Use CAM0 port (Monochrome)**:
```ini
dtoverlay=imx585,cam0,mono
```

Reboot your Raspberry Pi for the changes to take effect:
```bash
$ sudo reboot
```

---

## 4. I2C Tools & EEPROM Access

The camera module includes an on-board **FT24C02A EEPROM** (256 bytes) for storing calibration data and camera parameters. The `i2c-tools/` directory provides a Python-based utility for reading, writing, and managing EEPROM data over I2C.

### 4.1 EEPROM Overview

The FT24C02A is a single-chip EEPROM at I2C address **0x50**, providing 256 bytes of persistent storage. This is useful for:
- Storing camera calibration coefficients
- Saving sensor configuration parameters
- Preserving user-defined settings across power cycles

### 4.2 Using i2c-tools

The `i2c-tools/` folder contains:
- `i2c.py` - Python 3 utility (stdlib only, no external dependencies)
- `README.md` - Detailed usage documentation

**Quick Start**:

```bash
# Make the script executable
chmod +x i2c-tools/i2c.py

# Detect EEPROM chips on I2C bus 4 (CAM1 port on Pi5)
sudo python3 i2c-tools/i2c.py eeprom detect --bus 4

# Backup EEPROM to a file (recommended before any writes)
sudo python3 i2c-tools/i2c.py eeprom dump --bus 4 --out eeprom_backup.bin

# Read 16 bytes from EEPROM page 0x50 at offset 0
sudo python3 i2c-tools/i2c.py eeprom read --bus 4 --chip 0x50 --offset 0 --length 16

# Write calibration data to EEPROM
sudo python3 i2c-tools/i2c.py eeprom write --bus 4 --chip 0x50 --offset 0 --data 0xAA 0xBB 0xCC

# Restore from backup
sudo python3 i2c-tools/i2c.py eeprom restore --bus 4 --in eeprom_backup.bin
```

**Which I2C bus to use?** (Raspberry Pi 5)

| CSI Port | Bus Number |
| :--- | :--- |
| CAM1 | `--bus 4` |
| CAM0 | `--bus 6` |

Not sure? Run `ls /dev/i2c-*` to list available buses, then use `i2cdetect -y 4` (or `-y 6`) to confirm the camera is present — you should see the EEPROM chip at address 0x50.

**For detailed usage**, sensor register access, and troubleshooting, see `i2c-tools/README.md`.

---

## 5. Testing the Camera

After installation and rebooting, you can verify the camera detection and test its functionality using the standard `rpicam-apps`.

### 4.1 Verify Detection

List the available cameras to ensure the IMX585 is detected correctly:

```bash
rpicam-hello --list-cameras
```

### 4.2 Capture Commands

**Live Preview:**
```bash
rpicam-hello -t 0
```

**Capture a 4K Image:**
```bash
rpicam-still -o 4k_image.jpg --width 3856 --height 2180
```

**Record a 4K Video (30fps):**
```bash
rpicam-vid -t 10000 --width 3856 --height 2180 -o 4k_video.h264
```

---

## 7. Preset OS Image

A pre-configured Raspberry Pi OS image with all drivers and software pre-installed is available for download:

**Download**: [https://www.jianguoyun.com/p/DWqJpGAQpdSrBxil9p8GIAA](https://www.jianguoyun.com/p/DWqJpGAQpdSrBxil9p8GIAA)  
**Password**: `exgk55`

---

## 8. Support

For technical support, detailed documentation, and product inquiries, please visit [INNO-MAKER](https://www.inno-maker.com).
