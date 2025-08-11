#!/bin/busybox sh
set -eux -o pipefail
set | grep ^CRYPTTAB 1>&2
export CRYPTTAB_KEY

Main() {
    local mnt try
    mnt=$(mktemp -d /tmp/luXXXXXXXX)
    for usb in $(GetInteresting /dev/disk/by-id/usb-*); do
    :
        # # echo "$usb"
        if mount "${usb}" "${mnt}"
        then
            :
            try="${mnt}/${CRYPTTAB_KEY}.lek"
            if [ -r "${try}" ]
            then
                :
                cat "${try}"
                umount "${usb}"
                exit 0
            fi
            umount "${usb}"
        fi
    done
}
GetInteresting() {
    blkid --match-type vfat,exfat "$@" | awk -F': ' '{print $1}'
    # blkid "$@" |
    # awk '/LABEL="VTOYEFI"/||/LABEL="Ventoy"/||/LABEL="USB_ENC_KEY"/{print substr($1, 1, length($1)-1)}'
}
Main "$@"
exit 1