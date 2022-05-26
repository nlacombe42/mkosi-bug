#!/usr/bin/env bash

main() {
	printSystemInfo 2>&1 > host-system-info.log
	sudo mkosi 2>&1 | tee ./build.log
	printCommandAndOutput "ls -lh ./mkosi.output/"
}

printSystemInfo() {
	printCommandAndOutput "uname -a"
	printCommandAndOutput "cat /etc/os-release"
	printCommandAndOutput "pacman -Qs 'mkosi|systemd'"
}

printCommandAndOutput() {
	local command="$1"

	echo "$ $command"
	$command
}

main "$@"
