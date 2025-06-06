# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..13} pypy3 pypy3_11 )

inherit distutils-r1 pypi

DESCRIPTION="Math extension for Python-Markdown"
HOMEPAGE="
	https://github.com/mitya57/python-markdown-math/
	https://pypi.org/project/python-markdown-math/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm64 ~riscv x86"

RDEPEND="
	>=dev-python/markdown-3.3.7[${PYTHON_USEDEP}]
"
BDEPEND="
	>=dev-python/setuptools-77[${PYTHON_USEDEP}]
"

distutils_enable_tests unittest
