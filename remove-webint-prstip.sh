#!/usr/bin/env bash
# Copyright (c) 2023 rM-self-serve
# SPDX-License-Identifier: MIT

pkgname='webinterface-persist-ip'
removefile='./remove-webint-prstip.sh'
localbin='/home/root/.local/bin'
binfile="${localbin}/${pkgname}"
servicefile="/lib/systemd/system/${pkgname}.service"

remove_removefile() {
	read -r -p "Would you like to remove uninstallation script? [y/N] " response
	case "$response" in
	[yY][eE][sS] | [yY])
		echo "Exiting installer and removing script"
		[[ -f $removefile ]] && rm $removefile
		;;
	*)
		echo "Exiting installer and leaving script"
		;;
	esac
}

echo "Remove ${pkgname}"
echo ''
echo "This will not remove the /home/root/.local/bin directory nor the path in .bashrc"
echo ''

read -r -p "Would you like to continue with removal? [y/N] " response
case "$response" in
[yY][eE][sS] | [yY])
	echo "Removing ${pkgname}"
	;;
*)
	echo "Exiting removal"
	remove_removefile
	exit
	;;
esac

[[ -f $binfile ]] && rm $binfile

if systemctl --quiet is-active "$pkgname" 2>/dev/null; then
	echo "Stopping $pkgname"
	systemctl stop "$pkgname"
fi
if systemctl --quiet is-enabled "$pkgname" 2>/dev/null; then
	echo "Disabling $pkgname"
	systemctl disable "$pkgname"
fi

[[ -f $servicefile ]] && rm $servicefile

echo "Successfully removed ${pkgname}"
echo ''

remove_removefile
