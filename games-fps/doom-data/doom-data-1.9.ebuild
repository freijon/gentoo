# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="The IWAD used by the shareware version of Doom"
HOMEPAGE="https://www.idsoftware.com"
SRC_URI="https://distro.ibiblio.org/pub/linux/distributions/slitaz/sources/packages/d/doom1.wad"

LICENSE="freedist"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~x86"

S="${DISTDIR}"

DOOMWADPATH="/usr/share/doom"

src_install() {
	insinto ${DOOMWADPATH}
	doins doom1.wad
}

pkg_postinst() {
	elog "Doom WAD file installed into the ${DOOMWADPATH} directory."
	elog "A Doom engine is required in order to play the doom1.wad file."
}
