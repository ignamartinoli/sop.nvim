#!/usr/bin/env sh
# Copyright 2022 ignamartinoli. GPL license.
set -euo

echo 'A'

if [ "$(uname -sm)" != 'Linux x86_64' ]; then
	>&2 echo 'Unsupported platform.'
	exit
fi

echo 'B'

if [ -x "$(command -v sudo)" ];
	then ADMIN='sudo'
elif [ -x "$(command -v doas)" ];
	then ADMIN='doas'
else
	>&2 echo 'Unsupported privilege authorization method.'
fi

# -=[ Main distributions ]=-
#
# apt (deb) - Debian, Ubuntu: apt-get install pkg
# zypp (rpm) - openSUSE: zypper install pkg
# yum/dnf (rpm) - Fedora, CentOS: dnf install pkg
# urpmi (rpm) - Mandriva, Mageia: urpmi pkg
#
# -=[ Slackware and Slackware-based distributions ]=-
# 
# slackpkg - Slackware: slackpkg install pkg
# slapt-get - Vector: slapt-get --install pkg
# netpkg - Zenwalk: netpkg pkg
#
# -=[ Independent Linux distributions ]=-
#
# equo - Sabayon: equo install pkg
# pacman - Arch: pacman -S pkg
# eopkg - Solus: eopkg install pkg
# apk - Alpine: apk add pkg
#
# -=[ Source-based distributions ]=-
# 
# portage - Gentoo: emerge pkg
#
# -=[ Nix OS and Void ]=-
# 
# nix - NixOS: nix-env -i pkg
# xbps - Void: xbps-install pkg
#
# -=[ FreeBSD ]=-
#
# packages - FreeBSD 10.0+: pkg install pkg

echo 'C'

PACKAGES='git npm nvim'

if   [ -x "$(command -v apt-get)" ];      then $ADMIN apt-get install "$PACKAGES"
elif [ -x "$(command -v zypper)" ];       then $ADMIN zypper install "$PACKAGES"
elif [ -x "$(command -v dnf)" ];          then $ADMIN dnf install "$PACKAGES"
elif [ -x "$(command -v urpmi)" ];        then $ADMIN urpmi "$PACKAGES"
elif [ -x "$(command -v slackpkg)" ];     then $ADMIN slackpkg install "$PACKAGES"
elif [ -x "$(command -v slapt-get)" ];    then $ADMIN slapt-get --install "$PACKAGES"
elif [ -x "$(command -v netpkg)" ];       then $ADMIN netpkg "$PACKAGES"
elif [ -x "$(command -v equo)" ];         then $ADMIN equo install "$PACKAGES"
elif [ -x "$(command -v pacman)" ];       then $ADMIN pacman -Sy "$PACKAGES"
elif [ -x "$(command -v eopkg)" ];        then $ADMIN eopkg install "$PACKAGES"
elif [ -x "$(command -v apk)" ];          then $ADMIN apk add "$PACKAGES"
elif [ -x "$(command -v emerge)" ];       then $ADMIN emerge "$PACKAGES"
elif [ -x "$(command -v nix-env)" ];      then $ADMIN nix-env -i "$PACKAGES"
elif [ -x "$(command -v xbps-install)" ]; then $ADMIN xbps-install "$PACKAGES"
elif [ -x "$(command -v pkg)" ];          then $ADMIN pkg install "$PACKAGES"
else >&2 echo 'Unsupported package manager.'
fi

# Administrador de paquetes

echo 'D'

git clone --depth 1 'https://github.com/wbthomason/packer.nvim' "$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"

# Config file

echo 'E'

# TODO: git vs curl
