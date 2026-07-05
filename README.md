# CAM-IMX585-Mono / CAM-IMX585-Color

![CAM-IMX585](imx585.png)

**8.3MP 4K MIPI Camera Module — Sony IMX585 Starvis 2 · Raspberry Pi 5 · NVIDIA Jetson Orin Nano**

---

## Overview

The **CAM-IMX585-Mono** and **CAM-IMX585-Color** are professional-grade MIPI camera modules built on the Sony IMX585 Starvis 2 back-illuminated CMOS sensor. The Mono variant delivers enhanced low-light sensitivity and near-infrared response; the Color variant provides full RGB imaging with the same 8.3MP 4K resolution.

Both models connect via a 4-lane MIPI CSI-2 interface and are supported on **Raspberry Pi 5** and **NVIDIA Jetson Orin Nano**. An on-board **FT24C02A EEPROM** (256 bytes, I2C 0x50) is available for calibration data storage.

---

## Key Features

| Feature | Details |
| :--- | :--- |
| **Sensor** | Sony IMX585 (Mono / Color) — Starvis 2 back-illuminated |
| **Resolution** | 8.3MP — 3840 × 2160 (4K UHD) |
| **Optical Format** | 1/1.2" |
| **Pixel Size** | 2.9 µm × 2.9 µm |
| **RAW Output** | 10 / 12 / 16-bit (driver-dependent) |
| **Interface** | MIPI CSI-2 4-lane, 1.5 Gbps/lane, 22-pin FPC |
| **Lens Mount** | CS-mount / M12 |
| **Dimensions** | 38 mm × 38 mm |
| **EEPROM** | FT24C02A, 256 bytes, I2C 0x50 |
| **Supported Platforms** | Raspberry Pi 5 · NVIDIA Jetson Orin Nano |

---

## Video Modes

| Resolution | Frame Rate | Format | Notes |
| :--- | :--- | :--- | :--- |
| 1928 × 1090 | 60 fps | R12_CSI2P | 1080p cropped |
| 3856 × 2180 | 30 fps | R12_CSI2P | 4K native (standard) |
| 3856 × 2180 | 30 fps | R12_CSI2P | 4K ClearHDR 12-bit ¹ |
| 3856 × 2180 | 30 fps | R16 | 4K ClearHDR 16-bit ¹ |

> ¹ ClearHDR modes require the **InnoMaker Unique Driver** (see below).

---

## Driver Options

Two driver options are available for Raspberry Pi 5:

| Driver | Standard 12-bit | ClearHDR 12-bit | ClearHDR 16-bit |
| :--- | :---: | :---: | :---: |
| **Open-source Driver** | ✅ | ❌ | ❌ |
| **InnoMaker Unique Driver** | ✅ | ✅ | ✅ |

### ClearHDR — InnoMaker Unique Feature

**ClearHDR 12-bit** compresses the sensor's HDR output into a standard 12-bit stream, delivering approximately 4× the contrast range of normal mode with no pipeline changes required.

**ClearHDR 16-bit** outputs the full uncompressed 16-bit gradation HDR stream, preserving the finest highlight roll-off for scientific and post-production workflows. Manual exposure is required (PiSP statistics do not support 16-bit data).

Both ClearHDR modes are enabled via a single `v4l2-ctl` register write and are toggled at runtime without rebooting.

---

## Repository Structure

| Path | Description |
| :--- | :--- |
| [`raspberry_pi_driver/`](./raspberry_pi_driver/) | All Raspberry Pi 5 driver packages and user manual |
| [`raspberry_pi_driver/UserManual.md`](./raspberry_pi_driver/UserManual.md) | Full installation, ClearHDR setup, and usage guide for Raspberry Pi 5 |
| [`raspberry_pi_driver/precompiler-driver/`](./raspberry_pi_driver/precompiler-driver/) | Pre-compiled kernel modules for specific OS/kernel versions |
| [`raspberry_pi_driver/pkg1-imx585-driver-v1.0-6.12y-offline.tar.gz`](./raspberry_pi_driver/pkg1-imx585-driver-v1.0-6.12y-offline.tar.gz) | Offline kernel driver source package |
| [`raspberry_pi_driver/pkg2-rpicam-libcamera-offline.tar.gz`](./raspberry_pi_driver/pkg2-rpicam-libcamera-offline.tar.gz) | Offline libcamera + rpicam-apps build package |
| [`jetson-orin-nano-driver/`](./jetson-orin-nano-driver/) | Jetson Orin Nano driver packages (contact sales for binary) |
| [`i2c-tools/`](./i2c-tools/) | Python utility for EEPROM read/write over I2C |
| [`i2c-tools/README.md`](./i2c-tools/README.md) | EEPROM usage documentation |
| [`CAM-IMX585-Mono-Color-User-Manual.pdf`](./CAM-IMX585-Mono-Color-User-Manual.pdf) | Hardware user manual (PDF) |

---

## Getting Started

### Raspberry Pi 5

Full installation instructions, device-tree options, ClearHDR setup, and capture commands are in:

> **[`raspberry_pi_driver/UserManual.md`](./raspberry_pi_driver/UserManual.md)**

Quick path:
1. Choose a driver option (pre-compiled or source compilation) — see `UserManual.md §1`
2. Configure `/boot/firmware/config.txt` with the appropriate `dtoverlay` — see `UserManual.md §2`
3. Reboot and verify with `rpicam-hello --list-cameras`

### NVIDIA Jetson Orin Nano

Driver packages for kernel `5.15.148-tegra` and `5.15.185-tegra` are in [`jetson-orin-nano-driver/`](./jetson-orin-nano-driver/). Contact [sales@inno-maker.com](mailto:sales@inno-maker.com) to obtain the binary.

### Preset OS Image

A pre-configured Raspberry Pi OS image with all drivers pre-installed is available:

**Download**: [https://www.jianguoyun.com/p/DWqJpGAQpdSrBxil9p8GIAA](https://www.jianguoyun.com/p/DWqJpGAQpdSrBxil9p8GIAA) · **Password**: `exgk55`

---

## Applications

- Security & Surveillance — 24/7 monitoring, near-IR night vision (Mono)
- Industrial & Machine Vision — AOI, robotics, precision inspection
- Broadcast & ProAV — live streaming, drone cameras
- Scientific & Medical — microscopy, diagnostics, high-DR imaging
- Automotive — ADAS, surround-view

---

## Support

- **Website**: [www.inno-maker.com](https://www.inno-maker.com)
- **Email**: [support@inno-maker.com](mailto:support@inno-maker.com)
