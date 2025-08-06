#!/bin/bash
set -eux -o pipefail
export CRYPTTAB_KEY
Main() {
    local mnt interesting=() try
    mnt=$(mktemp -d luXXXXXXXX)
    readarray -t interesting < <(shopt -s nullglob; GetInteresting /dev/disk/by-id/usb*)
    for usb in "${interesting[@]}"; do
        # echo "$usb"
        if mount "${usb}" "${mnt}"; then
            if [ -r "${mnt}/${CRYPTTAB_KEY}.lek" ]; then
                if cryptsetup 
                cat "${mnt}/${CRYPTTAB_KEY}.lek"
                umount "${usb}"
                exit 0
            fi
            umount "${usb}"
        fi
    done
}
GetInteresting() {
    blkid "$@" |
    awk '/LABEL="VTOYEFI"/||/LABEL="Ventoy"/||/LABEL="USB_ENC_KEY"/{print substr($1, 1, length($1)-1)}'
}
Main "$@"
exit 1