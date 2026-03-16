#!/bin/bash
set -e -u -o pipefail
set -x

export DEBIAN_FRONTEND=noninteractive

# Use new repo format
if ! [[ -r /etc/apt/sources.list.d/debian.sources ]]; then
  apt modernize-sources --assume-yes
fi

# Add contrib and non-free
if ! [[ -r /etc/apt/sources.list.d/debian-extra.sources ]]; then
  sed -e 's/main non-free-firmware/contrib non-free/' /etc/apt/sources.list.d/debian.sources > /etc/apt/sources.list.d/debian-extra.sources
  apt update
fi

# Add ZFS

if ! type -f zpool; then
  apt install -y linux-headers-amd64 zfsutils-linux
fi

# Add NFS

if ! type -f exportfs; then
  apt install -y nfs-kernel-server
fi

# Add aptitude

if ! type -f aptitude; then
  apt install -y aptitude
fi

# Add mise

if ! type -f mise; then
  apt install -y curl
  install -dm 755 /etc/apt/keyrings
  curl -fSs https://mise.jdx.dev/gpg-key.pub -o /etc/apt/keyrings/mise-archive-keyring.asc
  echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.asc] https://mise.jdx.dev/deb stable main" | tee /etc/apt/sources.list.d/mise.list
  apt modernize-sources -y
  apt update -y
  apt install -y mise
fi
