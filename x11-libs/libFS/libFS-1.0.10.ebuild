# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xorg-3

DESCRIPTION="X.Org FS library"

KEYWORDS="~alpha amd64 arm ~arm64 ~hppa ~mips ppc ppc64 ~s390 sparc x86"

DEPEND="
	x11-base/xorg-proto
	x11-libs/xtrans"

src_configure() {
	local XORG_CONFIGURE_OPTIONS=(
		--enable-ipv6
	)
	xorg-3_src_configure
}
