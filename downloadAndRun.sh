#!/usr/bin/env bash

main() {
	imageFilename="Arch-Linux-x86_64-basic-20220526.57805.qcow2"
	imageUrl="https://gitlab.archlinux.org/archlinux/arch-boxes/-/jobs/57805/artifacts/raw/output/$imageFilename"
	verificationFilename="$imageFilename.SHA256"
	verificationFileUrl="$imageUrl.SHA256"
	qemuDiskFilename="arch-qemu-disk.qcow2"

	if [ ! -f "$verificationFilename" ]; then
		curl -o "$verificationFilename" "$verificationFileUrl" || fatal "error downloading verification file"
	fi

	if [ ! -f "$imageFilename" ]; then
		curl -o "$imageFilename" "$imageUrl" || fatal "error downloading image file"
	fi

	rhash -c "$verificationFilename" || fatal "image file does not pass verification"
	cp "$imageFilename" "$qemuDiskFilename" || fatal "error copying image file to qemu disk file"
	qemu-system-x86_64 -machine q35 --accel kvm -m 2G -drive "index=0,media=disk,format=qcow2,file=$qemuDiskFilename"
}

fatal() {
	echo "$*"
	exit 1
}

main "$@"
