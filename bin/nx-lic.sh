#!/bin/bash
set -e -u -o pipefail
zero="$0"
zerodir="${0%/*}"
export DEBIAN_FRONTEND=noninteractive
Main() {
	local pid1
	pid1=$(< /proc/1/sched)
	case "$pid1" in
		systemd\ *|init\ *)
			NoDocker "$@";;
		*)
			Docker "$@";;
	esac
}
NoDocker() { 
	echo "NoDocker"
	head -1 /proc/1/sched
	: "${NXLICDIR:=/usr/NX/etc}"
	tarballdir="${1%/*}"
	tarball="${1##*/}"
	docker run --rm --interactive=false --tty=false --volume "$zerodir:/script:ro" -v "$tarballdir:/work:ro" -v "$NXLICDIR:/nxout" --workdir /work debian:latest "/script/${zero##*/}" "$tarball"
}
Docker() {
	echo "Docker"
	head -1 /proc/1/sched
	mkdir -p /usr/NX
	local tarball="$1"; shift
	apt update -qq
	apt install -qq -y adduser gawk procps
	tar -C /usr -xpf "$tarball"
	/usr/NX/nxserver --install
	cat /usr/NX/etc/server.lic
	cp /usr/NX/etc/*.lic /nxout

}
Main "$@"
