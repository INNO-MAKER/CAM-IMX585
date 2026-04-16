#!/bin/bash
# IMX585 Driver and IPA Library Auto-Install Script

set -e

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRIVER_SOURCE="$SCRIPT_DIR/imx585.ko"
IPA_SOURCE_DIR="$SCRIPT_DIR/ipa"

KERNEL_VERSION=$(uname -r)
DRIVER_DEST="/lib/modules/$KERNEL_VERSION/kernel/drivers/media/i2c"
IPA_BASE_DEST="/usr/lib/aarch64-linux-gnu/libcamera"

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Error: root privileges required${NC}"
        exit 1
    fi
}

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
error() { echo -e "${RED}[ERR]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

install_driver() {
    info "Installing IMX585 driver..."
    if [[ ! -f "$DRIVER_SOURCE" ]]; then
        error "Driver file not found: $DRIVER_SOURCE"
        exit 1
    fi
    mkdir -p "$DRIVER_DEST"
    cp -v "$DRIVER_SOURCE" "$DRIVER_DEST/"
    chmod 644 "$DRIVER_DEST/imx585.ko"
    depmod -a
    if modprobe imx585 2>/dev/null || insmod "$DRIVER_DEST/imx585.ko" 2>/dev/null; then
        success "Driver loaded"
    else
        warn "Driver load failed, may need reboot"
    fi
}

install_ipa() {
    info "Installing IPA libraries..."
    if [[ ! -d "$IPA_SOURCE_DIR" ]]; then
        error "IPA directory not found"
        exit 1
    fi
    
    local files=("ipa_rpi_pisp.so" "ipa_rpi_pisp.so.sign" "ipa_rpi_vc4.so" "ipa_rpi_vc4.so.sign")
    for f in "${files[@]}"; do
        local src="$IPA_SOURCE_DIR/$f"
        if [[ "$f" == *pisp* ]]; then
            local dest="$IPA_BASE_DEST/ipa/rpi/pisp/$f"
        else
            local dest="$IPA_BASE_DEST/ipa/rpi/vc4/$f"
        fi
        
        if [[ ! -f "$src" ]]; then
            warn "Skip: $f (not found)"
            continue
        fi
        
        mkdir -p "$(dirname "$dest")"
        [[ -f "$dest" ]] && mv "$dest" "$dest.backup.$(date +%Y%m%d%H%M%S)"
        cp -v "$src" "$dest"
        chmod 644 "$dest"
        success "Installed: $f"
    done
}

verify() {
    info "Verifying installation..."
    lsmod | grep -q imx585 && success "Driver loaded" || warn "Driver not loaded"
    v4l2-ctl --list-devices 2>/dev/null | head -10 || true
}

main() {
    echo -e "${GREEN}=== IMX585 Install Script ===${NC}"
    check_root
    install_driver
    install_ipa
    ldconfig
    verify
    echo -e "${GREEN}=== Done ===${NC}"
}

main
