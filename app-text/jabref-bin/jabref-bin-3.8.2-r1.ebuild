# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop java-pkg-2

MY_PV_1="${PV/_beta/b}"
MY_PV="${MY_PV_1/_rc/}"
MY_URI_PV_1="${PV/rc/}"
MY_URI_PV="${MY_URI_PV_1//_/%20}"

DESCRIPTION="Java GUI for managing BibTeX and other bibliographies"
HOMEPAGE="https://www.jabref.org/"
# SRC_URI="https://downloads.sourceforge.net/jabref/JabRef-${MY_PV}.jar"
SRC_URI="https://github.com/JabRef/jabref/releases/download/v${PV}/JabRef-${MY_PV}.jar"
S="${WORKDIR}"

LICENSE="MIT JSON"
SLOT="0"
KEYWORDS="amd64 x86"

RDEPEND="virtual/jre:1.8"
BDEPEND="app-arch/unzip"

src_unpack() {
	cp -v "${DISTDIR}/${A}" . || die
	unzip  ${A} images/icons/JabRef-icon-48.png || die
}

src_install() {
	java-pkg_newjar "JabRef-${MY_PV}.jar"
	java-pkg_dolauncher "${PN}" --jar "${PN}.jar"
	newicon images/icons/JabRef-icon-48.png JabRef-bin-icon.png
	make_desktop_entry "${PN}" JabRef-bin JabRef-bin-icon Office
}
