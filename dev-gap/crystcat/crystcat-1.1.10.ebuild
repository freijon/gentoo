# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit gap-pkg

DESCRIPTION="The crystallographic groups catalog"
SRC_URI="https://www.math.uni-bielefeld.de/~gaehler/gap/CrystCat/${P}.tar.gz"
S="${WORKDIR}/${PN}"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~riscv"

RDEPEND="dev-gap/cryst"

GAP_PKG_EXTRA_INSTALL=( grp )
gap-pkg_enable_tests
