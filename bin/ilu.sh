#!/bin/bash
set -eux -o pipefail
Main() {
    local usbblk=()
    readarray -t usbblk < <(GetUsb)
    echo usb: "${usbblk[@]}"
    local luksblk=()
    readarray -t luksblk < <(GetLuks)
    echo luks: "${luksblk[@]}"
    local keysrcblk=()
    readarray -t keysrcblk < <(GetKeySrc "${usbblk[@]}")
    echo keysrc: "${keysrcblk[@]}"
    local lukstgt
    lukstgt=$(GetLuksTgt "${luksblk[@]}")
    echo "${lukstgt}"
    local usbmounts=() 
    readarray -t usbmounts < <(GetUsbMounts "${usbblk[@]}")
    echo "${usbmounts[@]}"
    local hotleks=()
    readarray -t hotleks < <(GetHotLeks "$lukstgt" "${usbmounts[@]}")
    echo "${hotleks[@]}"
    
    exit 0
}
GetUsb() {
    for u in /dev/disk/by-id/usb-*; do
    echo "${u}"
    done
}
GetLuks() {
    blkid --match-token TYPE=crypto_LUKS -o device
}
GetKeySrc() {
    # Might want to limit this
    blkid --match-type vfat,exfat "$@" | awk -F': ' '{print $1}'
}
GetLuksTgt() {
    local tgt="$1"
    if [ "${#}" -gt 1 ]; then
        select tgt in "$@"; do break; done
    fi
    echo "$tgt"
}
GetUsbMounts() {
    awk 'NF==1{h[$1]++;next}h[$1]{print $2}' <(readlink -f "$@") /proc/mounts
}
GetHotLeks() {
    local luksdev mnt keyfile
    luksdev="$1"; shift
    for mnt in "$@"; do
        for keyfile in "$mnt"/*.leks; do
            if cryptsetup luksOpen --verbose --test-passphrase --key-file "$keyfile" "$luksdev" < /dev/null 1>&2; then
            echo "$keyfile"
            fi
        done
    done
}
Main "$@"
# shellcheck disable=SC2317
exit 1