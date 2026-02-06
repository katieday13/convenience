#!/bin/bash
set -e -u -o pipefail

# We don't want mailutils so...
sudo apt install --no-install-recommends -y emacs
# We do want to build vterm
sudo apt intall -y cmake libtool-bin libvterm-dev
