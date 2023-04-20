#!/usr/bin/env bash
# Copyright (c) 2023 rM-self-serve
# SPDX-License-Identifier: MIT

persist_ip_sha256sum='d80071119b3a1f7c799ea4ab144a720769f847b127d83abeaff9d177f3cdf46e'
service_file_sha256sum='b72d411cb108aeebeaece19de5fb29c96f9e0742a5d43d0c550c1447af9596ae'

release='v1.0.0'

installfile='./install-webint-prstip.sh'
pkgname='webinterface-persist-ip'
localbin='/home/root/.local/bin'
binfile="${localbin}/${pkgname}"
servicefile="/lib/systemd/system/${pkgname}.service"

remove_installfile() {
	read -r -p "Would you like to remove installation script? [y/N] " response
	case "$response" in
	[yY][eE][sS] | [yY])
		printf "Exiting installer and removing script\n"
		[[ -f $installfile ]] && rm $installfile
		;;
	*)
		printf "Exiting installer and leaving script\n"
		;;
	esac
}

echo "${pkgname} ${release}"
echo "Ensure the web interface is internally accessible after disconnecting the usb cable."
echo ''
echo "This program will be installed in ${localbin}"
echo "${localbin} will be added to the path in ~/.bashrc if necessary"
echo ''
read -r -p "Would you like to continue with installation? [y/N] " response
case "$response" in
[yY][eE][sS] | [yY])
	echo "Installing ${pkgname}"
	;;
*)
	remove_installfile
	exit
	;;
esac

mkdir -p $localbin

case :$PATH: in
*:$localbin:*) ;;
*) echo "PATH=\"${localbin}:\$PATH\"" >>/home/root/.bashrc ;;
esac

pkg_sha_check() {
	if sha256sum -c <(echo "$persist_ip_sha256sum  $binfile") >/dev/null 2>&1; then
		return 0
	else
		return 1
	fi
}

srvc_sha_check() {
	if sha256sum -c <(echo "$service_file_sha256sum  $servicefile") >/dev/null 2>&1; then
		return 0
	else
		return 1
	fi
}

sha_fail() {
	echo "sha256sum did not pass, error downloading ${pkgname}"
	echo "Exiting installer and removing installed files"
	[[ -f $binfile ]] && rm $binfile
	[[ -f $servicefile ]] && rm $servicefile
	remove_installfile
	exit
}

need_bin=true
if [ -f $binfile ]; then
	if pkg_sha_check; then
		need_bin=false
		echo "Already have the right version of ${pkgname}"
	else
		rm $binfile
	fi
fi
if [ "$need_bin" = true ]; then
	wget "https://github.com/rM-self-serve/${pkgname}/releases/download/${release}/${pkgname}" \
		-O "$binfile"

	if ! pkg_sha_check; then
		sha_fail
	fi

	chmod +x "${localbin}/${pkgname}"
fi

need_service=true
if [ -f $servicefile ]; then
	if srvc_sha_check; then
		need_service=false
		echo "Already have the right version of ${pkgname}"
	else
		rm $servicefile
	fi
fi
if [ "$need_service" = true ]; then
	wget "https://github.com/rM-self-serve/${pkgname}/releases/download/${release}/${pkgname}.service" \
		-O "$servicefile"

	if ! srvc_sha_check; then
		sha_fail
	fi
fi

systemctl daemon-reload

echo ""
echo "Finished installing ${pkgname}"
echo ""
echo "To use ${pkgname}, run:"
echo "$ systemctl enable --now ${pkgname}"
echo ""

remove_installfile
