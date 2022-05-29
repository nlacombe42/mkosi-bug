#!/usr/bin/env bash

main() {
	info "getting latest arch vm image url..."

	local imageListUrl
	imageListUrl=$(curl -s 'https://archlinux.org/download/' | grep -oE 'https://gitlab\.archlinux\.org/archlinux/arch-boxes/-/[^"]+') || fatal "error getting latest gitlab arch vm image list"
	local imagePath
	imagePath=$(curl -sL "$imageListUrl" | grep -oE '/archlinux/[^"]+/Arch-Linux-x86_64-basic[^"]+' | head -1 | sed 's/\/file\//\/raw\//') || fatal "error getting arch vm image url from image list page"
	local imageUrl="https://gitlab.archlinux.org$imagePath"
	local imageFilename=$(echo "$imageUrl" | grep -oE '/[^/]+$' | cut -c2-)
	local verificationFilename="$imageFilename.SHA256"
	local verificationFileUrl="$imageUrl.SHA256"
	local qemuDiskFilename="arch-qemu-disk.qcow2"

	if [ ! -f "$verificationFilename" ]; then
		info "downloading arch vm image verification file..."
		curl -Lo "$verificationFilename" "$verificationFileUrl" || fatal "error downloading verification file"
	fi

	if [ ! -f "$imageFilename" ]; then
		info "downloading arch image file..."
		curl -Lo "$imageFilename" "$imageUrl" || fatal "error downloading image file"
	fi

	info "verifying arch vm image..."
	rhash -c "$verificationFilename" || fatal "image file does not pass verification"
	info "copying arch vm image..."
	cp "$imageFilename" "$qemuDiskFilename" || fatal "error copying image file to qemu disk file"
	info "running qemu..."
	qemu-system-x86_64 -machine q35 --accel kvm -m 2G -drive "index=0,media=disk,format=qcow2,file=$qemuDiskFilename"
}

info() {
	echo "$*"
}

fatal() {
	echo "$*"
	exit 1
}

main "$@"
