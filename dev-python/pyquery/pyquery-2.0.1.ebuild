# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} pypy3_11 )

inherit distutils-r1 optfeature pypi

DESCRIPTION="A jQuery-like library for python"
HOMEPAGE="
	https://github.com/gawel/pyquery/
	https://pypi.org/project/pyquery/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~loong ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~x64-macos"

RDEPEND="
	>=dev-python/lxml-2.1[${PYTHON_USEDEP}]
	>=dev-python/cssselect-1.2.0[${PYTHON_USEDEP}]
"
DEPEND="
	test? (
		dev-python/beautifulsoup4[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
		dev-python/webtest[${PYTHON_USEDEP}]
		dev-python/webob[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest

python_test() {
	local EPYTEST_DESELECT=(
		# needs network
		tests/test_pyquery.py::TestWebScrappingEncoding::test_get
	)

	local -x PYTEST_DISABLE_PLUGIN_AUTOLOAD=1
	epytest
}

pkg_postinst() {
	optfeature "Support for BeautifulSoup3 as a parser backend" dev-python/beautifulsoup4
}
