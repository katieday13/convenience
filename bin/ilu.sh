#!/bin/bash
set -eux -o pipefail
Main() {
    local usbblk=() luksblk=() keysrcblk=()
    readarray -t usbblk < <(GetUsb)
    echo usb: "${usbblk[@]}"
    readarray -t luksblk < <(GetLuks)
    echo luks: "${luksblk[@]}"
    readarray -t keysrcblk < <(GetKeySrc "${usbblk[@]}")
    echo keysrc: "${keysrcblk[@]}"
    exit 0
}
GetUsb() {
    for u in /dev/disk/by-id/usb-*; do
    echo "${u}"
    done
}
GetLuks() {
    blkid --match-token TYPE=crypto_LUKS
}
GetKeySrc() {
    # Might want to limit this
    blkid --match-type vfat,exfat "$@" | awk -F': ' '{print $1}'
}

Main "$@"
# shellcheck disable=SC2317
exit 1