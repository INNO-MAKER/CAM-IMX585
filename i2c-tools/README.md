# i2c-tools — IMX585 Camera (on-board EEPROM)

A single Python script (`i2c.py`) that lets you read / write the on-board
**FT24C02A** EEPROM (256 bytes) on the **CAM-IMX585** module over I2C.

It also works as a drop-in replacement for the prebuilt `i2c_read` /
`i2c_write` C binaries — same arguments, no compilation needed — so you
can use it for any other register access on the bus.

No external dependencies — uses Python 3 stdlib only and talks to
`/dev/i2c-N` directly. Tested on Raspberry Pi OS Bookworm and Trixie,
both 32-bit and 64-bit.

## Which `--bus` number to use? (Raspberry Pi 5)

Every command below takes `--bus N` — that number tells the script which
I2C bus to talk on, which depends on **which CSI port on the Pi5 your
camera ribbon is plugged into**. The bus number has nothing to do with
the camera or the EEPROM — it is decided by the Pi5 hardware itself.

| CSI port on the Pi5 | use this `--bus` |
|---------------------|------------------|
| CAM1                | `--bus 4`        |
| CAM0                | `--bus 6`        |

Not sure? Run `ls /dev/i2c-*` to see which buses exist, then
`i2cdetect -y 4` (or `-y 6`) to confirm which one the camera is on —
you should see the EEPROM chip at `0x50`.

## Quick start

```bash
sudo chmod +x i2c.py

# Sanity check: should print "EEPROM chips found: 0x50"
sudo python3 i2c.py eeprom detect --bus 4
```

## EEPROM

The board has an FT24C02A — a single chip at address **0x50** with 256 bytes total.

```bash
# Confirm the chip ACKs
sudo python3 i2c.py eeprom detect --bus 4

# Back up everything to a file (do this BEFORE writing anything)
sudo python3 i2c.py eeprom dump --bus 4 --out cal_$(date +%Y%m%d).bin

# Read 16 bytes from offset 0
sudo python3 i2c.py eeprom read --bus 4 --chip 0x50 --offset 0 --length 16

# Write a few bytes
sudo python3 i2c.py eeprom write --bus 4 --chip 0x50 --offset 0 --data 0xAA 0xBB 0xCC

# Write a binary blob from a file
sudo python3 i2c.py eeprom write --bus 4 --chip 0x50 --offset 0 --from-file payload.bin

# Restore a previous full dump (must be exactly 256 bytes)
sudo python3 i2c.py eeprom restore --bus 4 --in cal_20260425.bin

# Erase everything (DESTRUCTIVE — note the required --yes flag)
sudo python3 i2c.py eeprom clear --bus 4 --yes
```

Tip: `eeprom write` automatically respects the chip's 16-byte hardware
page boundary. The FT24C02A has a single 256-byte address space at 0x50,
so there is no chip rollover.

## Low-level (drop-in for `i2c_read` / `i2c_write`)

```bash
# Same argument order as the original C tools.
# EEPROM uses 8-bit register addressing:
sudo python3 i2c.py read  4 0x50 0x00 16    --reg-bits 8
sudo python3 i2c.py write 4 0x50 0x00 0xAA  --reg-bits 8

# IMX585 sensor itself uses 16-bit register addressing (default):
sudo python3 i2c.py read  4 0x1a 0x3000 1
```

Slave addresses accept either the 7-bit form (`0x1a`, `0x50`) or the
8-bit "write address" form (`0x34`, `0xA0`). The 8-bit form is
auto-detected and shifted, matching the original C tool.

## Troubleshooting

| Symptom                                       | Likely cause                                          |
|-----------------------------------------------|-------------------------------------------------------|
| `FATAL: /dev/i2c-4 not found`                 | I2C disabled in raspi-config, or wrong bus number     |
| `device did not ACK (errno=…)`                | Wrong slave addr, no camera on that port, or stream is running |
| `eeprom detect` sees no chip                  | Confirm with `i2cdetect -y 4` — chip should appear at `0x50` |
| Empty / 0xFF readback after write             | Stream was running and the kernel driver re-wrote the bus — stop streaming and retry |

## Files

- `i2c.py` — the tool (Python 3, stdlib only)
- `README.md` — this file
