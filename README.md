# CAM-IMX585-Mono/CAM-IMX585-Color MIPI Camera Module

![CAM-IMX585](imx585.png)

## 1. Product Overview

The **CAM-IMX585-Mono** and **CAM-IMX585-Color** are high-performance CMOS image sensors designed for demanding imaging applications in embedded systems. The **Mono** variant features a monochrome sensor for enhanced low-light sensitivity, while the **Color** variant provides full RGB color imaging. Both feature an advanced Starvis 2 back-illuminated pixel structure, delivering 8.3MP resolution with exceptional low-light performance, high dynamic range, and precise image quality across diverse lighting conditions.

With native 3840×2160 (4K UHD) resolution and support for 10/12/16-bit RAW output, the CAM-IMX585-Mono/Color enables professional-grade imaging for surveillance, industrial inspection, machine vision, and embedded vision applications. The sensor's MIPI CSI-2 4-lane interface ensures reliable high-speed data transmission to host processors like Raspberry Pi 5 and NVIDIA Jetson. The on-board **FT24C08A EEPROM** (1 KB) supports camera calibration data storage and I2C-based read/write operations.

*Note: While the sensor supports 10/12/16-bit RAW output, the current driver configuration operates in 12-bit RAW (R12_CSI2P) mode on Raspberry Pi 5.*

### 1.1 Key Features

- **8.3MP 4K resolution** with Starvis 2 technology
- **Monochrome (Mono)** sensor for enhanced low-light sensitivity / **Color (RGB)** sensor for full-spectrum imaging
- **MIPI CSI-2 4-lane** high-speed interface
- **10/12/16-bit RAW output capability** (currently 12-bit)
- **Excellent low-light performance** with back-illuminated pixels
- **On-board EEPROM** (FT24C08A) for calibration data storage
- **I2C interface** for EEPROM and sensor register access
- **Compatible with Raspberry Pi**

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
| 1928×1090 | 30.00 fps | R12_CSI2P | Cropped from 4K |
| 3856×2180 | 30.00 fps | R12_CSI2P | Native sensor readout |

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

This repository provides the necessary drivers, Image Processing Algorithm (IPA) modules, and an automated installation script to enable full support for the IMX585 sensor on Raspberry Pi.

### 3.1 Repository Contents

- `pkg1-imx585-driver-6.12y-offline.tar.gz`: Offline driver build package.
- `pkg2-rpicam-libcamera-offline.tar.gz`: Offline libcamera build package.

### 3.2 Step 1: Offline Driver Compilation

For advanced users who need to compile the driver from source:

**Package**: `pkg1-imx585-driver-6.12y-offline.tar.gz`

**Contents**:
- `imx585-v4l2-driver/` - Kernel driver source code
- `install.sh` - Automated driver installation script

**Installation**:
```bash
$ tar -xzf pkg1-imx585-driver-6.12y-offline.tar.gz
$ cd pkg1-imx585-driver
$ chmod +x install.sh
$ sudo ./install.sh
```

### 3.3 Step 2: Offline libcamera & rpicam-apps Compilation

For complete offline compilation of libcamera with IMX585 support and rpicam-apps:

**Package**: `pkg2-rpicam-libcamera-offline.tar.gz`

**Contents**:
- `libcamera-imx585/` - libcamera source with IMX585 IPA support
- `rpicam-apps-imx585/` - rpicam-apps source
- `build.sh` - Automated build and installation script

**Installation**:
```bash
$ tar -xzf pkg2-rpicam-libcamera-offline.tar.gz
$ cd pkg2-rpicam-offline
$ chmod +x build.sh
$ sudo ./build.sh           # Full mode with Qt support
$ sudo ./build.sh --lite    # Lite mode (minimal dependencies)
```

**Build Time**: ~30-40 minutes (full mode) or ~15-20 minutes (lite mode)

### 3.4 Manual Configuration

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

The camera module includes an on-board **FT24C08A EEPROM** (1 KB total) for storing calibration data and camera parameters. The `i2c-tools/` directory provides a Python-based utility for reading, writing, and managing EEPROM data over I2C.

### 4.1 EEPROM Overview

The EEPROM consists of four 256-byte pages at I2C addresses **0x50, 0x51, 0x52, 0x53**, providing 1 KB of persistent storage. This is useful for:
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

Not sure? Run `ls /dev/i2c-*` to list available buses, then use `i2cdetect -y 4` (or `-y 6`) to confirm the camera is present — you should see EEPROM chips at addresses 0x50–0x53.

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

## 6. Support

For technical support, detailed documentation, and product inquiries, please visit [INNO-MAKER](https://www.inno-maker.com).
