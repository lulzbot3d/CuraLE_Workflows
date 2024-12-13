#!/bin/bash

set -e
apt install build-essential checkinstall libegl-dev zlib1g-dev libssl-dev ninja-build autoconf libx11-dev libx11-xcb-dev libfontenc-dev libice-dev libsm-dev libxau-dev libxaw7-dev libxcomposite-dev libxcursor-dev libxdamage-dev libxdmcp-dev libxext-dev libxfixes-dev libxi-dev libxinerama-dev libxkbfile-dev libxmu-dev libxmuu-dev libxpm-dev libxrandr-dev libxrender-dev libxres-dev libxss-dev libxt-dev libxtst-dev libxv-dev libxvmc-dev libxxf86vm-dev xtrans-dev libxcb-render0-dev libxcb-render-util0-dev libxcb-xkb-dev libxcb-icccm4-dev libxcb-image0-dev libxcb-keysyms1-dev libxcb-randr0-dev libxcb-shape0-dev libxcb-sync-dev libxcb-xfixes0-dev libxcb-xinerama0-dev xkb-data libxcb-dri3-dev uuid-dev libxcb-util-dev libxkbcommon-x11-dev libxcb-cursor-dev libxcb-glx0-dev libxcb-dri2-0-dev libxcb-present-dev libxcb-composite0-dev libxcb-ewmh-dev libxcb-res0-dev pkg-config flex bison libfreetype-dev patchelf jq -y

# Use GCC-13 as a minimum version
highest_version=$(update-alternatives --list gcc | awk -F'-' '{print $2}' | sort -V | tail -1)
current_version_number=$(echo "$highest_version" | awk -F'.' '{print $1}')
if (( current_version_number < 13 )); then
    echo "::notice::Upgrading GCC version to 13 and setting it as the default."
    add-apt-repository ppa:ubuntu-toolchain-r/test -y
    apt install -y g++-13 gcc-13
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 13
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 13
    update-alternatives --set gcc /usr/bin/gcc-13
    update-alternatives --set g++ /usr/bin/g++-13
else
    echo "::notice::Setting GCC $highest_version as the default."
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-$highest_version $current_version_number
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-$highest_version $current_version_number
    update-alternatives --set gcc /usr/bin/gcc-$highest_version
    update-alternatives --set g++ /usr/bin/g++-$highest_version
fi
