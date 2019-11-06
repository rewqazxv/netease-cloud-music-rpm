#!/bin/bash -x

DEBURL="https://d1.music.126.net/dmusic/netease-cloud-music_1.2.1_amd64_ubuntu_20190428.deb"
DEB="netease-cloud-music_1.2.1_amd64_ubuntu_20190428.deb"
DIR="netease-cloud-music-1.2.1"

RPM="netease-cloud-music-1.2.1-2.x86_64.rpm"

__error() {
    echo "Error: " "$1" >&2
    exit 1
}

__has() {
    type "$1" >/dev/null 2>&1
}

__test_and_install() {
    if ! __has $1; then
        sudo yum install -y $2
    fi
}

_init() {
    __test_and_install alien alien
    __test_and_install rpmbuild rpm-build
    __test_and_install wget wget
}

main() {
    _init

    local rmflag='true'
    if [[ -d "$HOME/rpmbuild" ]]; then
        rmflag='false'
    fi

    wget $DEBURL
    alien -rg $DEB
    cd $DIR
    sed -i '/^%define _rpmdir.*/a %define __requires_exclude libqcef.so.1' *.spec
    DIRTORM=(
        "/"
        "/opt/"
        "/usr/"
        "/usr/bin/"
        "/usr/share/"
        "/usr/share/applications/"
        "/usr/share/doc/"
        "/usr/share/icons/"
        "/usr/share/icons/hicolor/"
        "/usr/share/icons/hicolor/scalable/"
        "/usr/share/icons/hicolor/scalable/apps/"
    )
    for i in ${DIRTORM[@]}; do
        local j=$(echo $i | sed 's/\//\\\//g')
        sed -i "/\"${j}\"/d" *.spec
    done
    rpmbuild --buildroot="$PWD" -bb --target x86_64 *.spec

    cd ..
    rm $DEB

    if [[ $rmflag == 'true' ]]; then
        rm -rf "$HOME/rpmbuild"
    fi
}

main "$@"
