# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LUA_REQ_USE="deprecated(+)"
LUA_COMPAT=( lua5-{1,2} luajit )

PYTHON_COMPAT=( python3_{11..14} )

inherit flag-o-matic lua-single meson python-any-r1 xdg

DESCRIPTION="Enlightenment Foundation Libraries all-in-one package"
HOMEPAGE="https://www.enlightenment.org"
SRC_URI="https://download.enlightenment.org/rel/libs/${PN}/${P}.tar.xz"

LICENSE="BSD-2 GPL-2 LGPL-2.1 ZLIB"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 ~ppc ~ppc64 ~riscv x86"
IUSE="+X avif bmp connman cpu_flags_arm_neon dds debug doc drm +eet efl-one elogind examples fbcon"
IUSE+=" +fontconfig fribidi gif glib +gstreamer harfbuzz heif hyphen ibus ico jpeg2k jpegxl json"
IUSE+=" nls mono opengl +pdf physics pmaps postscript psd pulseaudio raw scim sdl +sound +svg"
IUSE+=" +system-lz4 systemd tga tgv tiff tslib unwind v4l vnc wayland webp xcf xim xpm xpresent"
IUSE+=" zeroconf"

REQUIRED_USE="${LUA_REQUIRED_USE}
	?? ( elogind systemd )
	?? ( fbcon tslib )
	drm? ( wayland )
	examples? ( eet svg )
	gstreamer? ( sound )
	ibus? ( glib )
	opengl? ( X )
	pulseaudio? ( sound )
	xim? ( X )
	xpresent? ( X )"

# Requires everything to be enabled unconditionally.
RESTRICT="test"

RDEPEND="${LUA_DEPS}
	dev-libs/libinput:=
	dev-libs/libunibreak:=
	dev-libs/openssl:0=
	net-misc/curl
	media-libs/giflib:=
	media-libs/libjpeg-turbo:=
	media-libs/libpng:=
	sys-apps/dbus
	sys-apps/util-linux
	sys-libs/zlib
	X? (
		!opengl? ( media-libs/libglvnd )
		media-libs/freetype
		x11-libs/libX11
		x11-libs/libXScrnSaver
		x11-libs/libXcomposite
		x11-libs/libXcursor
		x11-libs/libXdamage
		x11-libs/libXext
		x11-libs/libXfixes
		x11-libs/libXi
		x11-libs/libXinerama
		x11-libs/libXrandr
		x11-libs/libXrender
		x11-libs/libXtst
		x11-libs/libxkbcommon
		wayland? ( x11-libs/libxkbcommon[X] )
	)
	avif? ( media-libs/libavif:= )
	connman? ( net-misc/connman )
	drm? (
		dev-libs/libinput:=
		dev-libs/wayland
		media-libs/mesa[gbm(+)]
		x11-libs/libdrm
		x11-libs/libxkbcommon
	)
	elogind? (
		sys-auth/elogind
		virtual/libudev:=
	)
	fontconfig? (
		media-libs/fontconfig
		media-libs/freetype
	)
	fribidi? ( dev-libs/fribidi )
	glib? ( dev-libs/glib:2 )
	gstreamer? (
		media-libs/gstreamer:1.0
		media-libs/gst-plugins-base:1.0
	)
	harfbuzz? ( media-libs/harfbuzz:= )
	heif? ( media-libs/libheif:= )
	hyphen? ( dev-libs/hyphen )
	ibus? ( app-i18n/ibus )
	jpeg2k? ( media-libs/openjpeg:= )
	jpegxl? ( media-libs/libjxl:= )
	json? ( >=media-libs/rlottie-0.0.1_pre20200424:= )
	mono? ( dev-lang/mono )
	opengl? ( virtual/opengl )
	pdf? ( app-text/poppler:=[cxx] )
	physics? ( sci-physics/bullet:= )
	postscript? ( app-text/libspectre )
	pulseaudio? ( media-libs/libpulse )
	raw? ( media-libs/libraw:= )
	scim? ( app-i18n/scim )
	sdl? ( media-libs/libsdl2 )
	sound? ( media-libs/libsndfile )
	svg? ( gnome-base/librsvg:2 )
	system-lz4? ( app-arch/lz4:= )
	systemd? ( sys-apps/systemd:= )
	tiff? ( media-libs/tiff:= )
	tslib? ( x11-libs/tslib:= )
	unwind? ( sys-libs/libunwind:= )
	v4l? ( media-libs/libv4l )
	vnc? ( net-libs/libvncserver )
	wayland? (
		dev-libs/wayland
		media-libs/libglvnd
		media-libs/mesa[wayland]
		x11-libs/libxkbcommon
	)
	webp? ( media-libs/libwebp:= )
	xpm? ( x11-libs/libXpm )
	xpresent? ( x11-libs/libXpresent )
	zeroconf? ( net-dns/avahi )"
DEPEND="${RDEPEND}
	X? ( x11-base/xorg-proto )
	wayland? ( dev-libs/wayland-protocols )"
BDEPEND="${PYTHON_DEPS}
	virtual/pkgconfig
	doc? ( app-text/doxygen )
	examples? ( sys-devel/gettext )
	mono? ( dev-build/cmake )
	nls? ( sys-devel/gettext )
	wayland? ( dev-util/wayland-scanner )"

pkg_setup() {
	# Deprecated, provided for backward-compatibility. Everything is moved to libefreet.so.
	QA_FLAGS_IGNORED="/usr/$(get_libdir)/libefreet_trash.so.${PV}
		/usr/$(get_libdir)/libefreet_mime.so.${PV}"

	python-any-r1_pkg_setup
}

src_prepare() {
	default

	# Remove automagic unwind configure option, #743154
	if ! use unwind; then
		sed -i "/config_h.set('HAVE_UNWIND/,/eina_ext_deps += unwind/d" src/lib/eina/meson.build ||
			die "Failed to remove libunwind dep"
	fi

	# Fix python shebangs for python-exec[-native-symlinks], #764086
	local shebangs=($(grep -rl "#!/usr/bin/env python3" || die))
	python_fix_shebang -q ${shebangs[*]}
}

src_configure() {
	local emesonargs=(
		-Dbuffer=false
		-Dbuild-tests=false
		-Dcocoa=false
		-Ddrm-deprecated=false
		-Dembedded-libunibreak=false
		-Dg-mainloop=false
		-Dmono-beta=false
		-Ddotnet=false
		-Dpixman=false
		-Dwl-deprecated=false

		-Dedje-sound-and-video=true
		-Deeze=true
		-Dinput=true
		-Dinstall-eo-files=true
		-Dlibmount=true
		-Dnative-arch-optimization=true
		-Dxinput2=true
		-Dxinput22=true

		-Dcrypto=openssl
		-Ddotnet-stylecop-severity=Warning

		$(meson_use X x11)
		$(meson_use debug debug-threads)
		$(meson_use doc docs)
		$(meson_use drm)
		$(meson_use examples build-examples)
		$(meson_use fbcon fb)
		$(meson_use fontconfig)
		$(meson_use fribidi)
		$(meson_use glib)
		$(meson_use gstreamer)
		$(meson_use harfbuzz)
		$(meson_use hyphen)
		$(meson_use lua_single_target_luajit elua)
		$(meson_use nls)
		$(meson_use physics)
		$(meson_use pulseaudio)
		$(meson_use sdl)
		$(meson_use sound audio)
		$(meson_use tslib)
		$(meson_use v4l v4l2)
		$(meson_use vnc vnc-server)
		$(meson_use wayland wl)
		$(meson_use xpresent)
		$(meson_use zeroconf avahi)

		$(meson_use !system-lz4 embedded-lz4)
	)

	if use elogind || use systemd; then
		emesonargs+=( -D systemd=true )
	else
		emesonargs+=( -D systemd=false )
	fi

	if use wayland; then
		emesonargs+=( -D opengl=es-egl )
	elif ! use wayland && use opengl; then
		emesonargs+=( -D opengl=full )
	elif ! use wayland && use X && ! use opengl; then
		emesonargs+=( -D opengl=es-egl )
	else
		emesonargs+=( -D opengl=none )
	fi

	if use connman; then
		emesonargs+=( -D network-backend=connman )
	else
		emesonargs+=( -D network-backend=none )
	fi

	local disabledEvasLoaders=""
	! use avif && disabledEvasLoaders="avif,"
	! use bmp && disabledEvasLoaders+="bmp,wbmp,"
	! use dds && disabledEvasLoaders+="dds,"
	! use eet && disabledEvasLoaders+="eet,"
	! use gstreamer && disabledEvasLoaders+="gst,"
	! use heif && disabledEvasLoaders+="heif,"
	! use ico && disabledEvasLoaders+="ico,"
	! use jpeg2k && disabledEvasLoaders+="jp2k,"
	! use jpegxl && disabledEvasLoaders+="jxl,"
	! use json && disabledEvasLoaders+="json,"
	! use pdf && disabledEvasLoaders+="pdf,"
	! use pmaps && disabledEvasLoaders+="pmaps,"
	! use postscript && disabledEvasLoaders+="ps,"
	! use psd && disabledEvasLoaders+="psd,"
	! use raw && disabledEvasLoaders+="raw,"
	! use svg && disabledEvasLoaders+="rsvg,svg,"
	! use tga && disabledEvasLoaders+="tga,"
	! use tgv && disabledEvasLoaders+="tgv,"
	! use tiff && disabledEvasLoaders+="tiff,"
	! use webp && disabledEvasLoaders+="webp,"
	! use xcf && disabledEvasLoaders+="xcf,"
	! use xpm && disabledEvasLoaders+="xpm,"
	[[ ! -z "$disabledEvasLoaders" ]] && disabledEvasLoaders=${disabledEvasLoaders::-1}
	emesonargs+=( -D evas-loaders-disabler="${disabledEvasLoaders}" )

	local disabledImfLoaders=""
	! use ibus && disabledImfLoaders+="ibus,"
	! use scim && disabledImfLoaders+="scim,"
	! use xim && disabledImfLoaders+="xim,"
	[[ ! -z "$disabledImfLoaders" ]] && disabledImfLoaders=${disabledImfLoaders::-1}
	emesonargs+=( -D ecore-imf-loaders-disabler="${disabledImfLoaders}" )

	local bindingsList="cxx,"
	use lua_single_target_luajit && bindingsList+="lua,"
	use mono && bindingsList+="mono,"
	[[ ! -z "$bindingsList" ]] && bindingsList=${bindingsList::-1}
	emesonargs+=( -D bindings="${bindingsList}" )

	local luaChoice=""
	if use lua_single_target_luajit; then
		luaChoice+="luajit"
	else
		luaChoice+="lua"
	fi
	emesonargs+=( -D lua-interpreter="${luaChoice}" )

	# Not all arm CPU's have neon instruction set, #722552
	if use arm && ! use cpu_flags_arm_neon; then
		emesonargs+=( -D native-arch-optimization=false )
	fi

	if use elibc_musl ; then
		append-cflags -D_LARGEFILE64_SOURCE
	fi

	# https://bugs.gentoo.org/944215
	# https://git.enlightenment.org/enlightenment/efl/issues/93
	append-cflags -std=gnu17

	meson_src_configure
}

src_compile() {
	meson_src_compile
}

src_install() {
	meson_src_install

	if use examples; then
		docompress -x /usr/share/doc/${PF}/examples/
		dodoc -r "${BUILD_DIR}"/src/examples/
	fi
}
