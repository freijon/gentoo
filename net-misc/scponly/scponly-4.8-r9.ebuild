# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit readme.gentoo-r1 toolchain-funcs autotools

DESCRIPTION="A tiny pseudoshell which only permits scp and sftp"
HOMEPAGE="https://github.com/scponly/scponly"
SRC_URI="https://downloads.sourceforge.net/scponly/${P}.tgz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="amd64 ~ppc sparc x86"
IUSE="chroot +sftp scp winscp gftp rsync unison subversion wildcards quota passwd logging"
REQUIRED_USE="
	|| ( sftp scp winscp rsync unison subversion )
"

RDEPEND="
	sys-apps/sed
	virtual/openssh
	chroot? ( acct-user/scponly acct-group/scponly )
	quota? ( sys-fs/quota )
	rsync? ( net-misc/rsync )
	subversion? ( dev-vcs/subversion )
	unison? ( net-misc/unison:= )
"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}/${P}-rsync.patch"
	"${FILESDIR}/${P}-gcc4.4.0.patch"
	"${FILESDIR}/${P}-sftp-server-path.patch"
	"${FILESDIR}/${P}-C23.patch"
)

src_prepare() {
	default

	# bug #900316
	eautoreconf
}

src_configure() {
	CFLAGS="${CFLAGS} ${LDFLAGS}" econf \
		--disable-restrictive-names \
		$(use_enable chroot chrooted-binary) \
		$(use_enable chroot chroot-checkdir) \
		$(use_enable winscp winscp-compat) \
		$(use_enable gftp gftp-compat) \
		$(use_enable scp scp-compat) \
		$(use_with sftp sftp-server "/usr/$(get_libdir)/misc/sftp-server") \
		$(use_enable quota quota-compat) \
		$(use_enable passwd passwd-compat) \
		$(use_enable rsync rsync-compat) \
		$(use_enable unison unison-compat) \
		$(use_enable subversion svn-compat) \
		$(use_enable subversion svnserv-compat) \
		$(use_enable logging sftp-logging-compat) \
		$(use_enable wildcards wildcards)
}

src_compile() {
	emake CC="$(tc-getCC)"
}

src_install() {
	emake DESTDIR="${D}" install

	dodoc AUTHOR BUILDING-JAILS.TXT CHANGELOG CONTRIB README SECURITY TODO

	if use chroot ; then
		local DOC_CONTENTS="You might want to run\n
			emerge --config =${CATEGORY}/${PF}\n
			\nto setup the chroot. Otherwise you will have to setup chroot
			manually. Please read the docs in /usr/share/doc/${PF} for more
			informations, also the SECURITY file."
		( docinto chroot; dodoc setup_chroot.sh config.h )
		# don't compress setup-script, so it is usable if necessary
		docompress -x /usr/share/doc/${PF}/chroot
		readme.gentoo_create_doc
	fi
}

pkg_config() {
	if ! use chroot ; then
		einfo "USE=chroot not enabled, nothing to configure."
		return
	fi

	myuser="scponly"
	myhome="/var/chroot/${myuser}"
	mysubdir="/pub"

	# pkg_postinst is based on ${S}/setup_chroot.sh.

	einfo "Collecting binaries and libraries..."

	# Binaries launched in sftp compat mode
	if has_version "=${CATEGORY}/${PF}[sftp]" ; then
		BINARIES="/usr/$(get_libdir)/misc/sftp-server"
	fi

	# Binaries launched by vanilla- and WinSCP modes
	if has_version "=${CATEGORY}/${PF}[scp]" || \
		has_version "=${CATEGORY}/${PF}[winscp]" ; then
		BINARIES="${BINARIES} /usr/bin/scp /bin/ls /bin/rm /bin/ln /bin/mv"
		BINARIES="${BINARIES} /bin/chmod /bin/chown /bin/chgrp /bin/mkdir /bin/rmdir"
	fi

	# Binaries launched in WinSCP compatibility mode
	if has_version "=${CATEGORY}/${PF}[winscp]" ; then
		BINARIES="${BINARIES} /bin/pwd /bin/groups /usr/bin/id /bin/echo"
	fi

	# Rsync compatability mode
	if has_version "=${CATEGORY}/${PF}[rsync]" ; then
		BINARIES="${BINARIES} /usr/bin/rsync"
	fi

	# Unison compatability mode
	if has_version "=${CATEGORY}/${PF}[unison]" ; then
		BINARIES="${BINARIES} /usr/bin/unison"
	fi

	# subversion cli/svnserv compatibility
	if has_version "=${CATEGORY}/${PF}[subversion]" ; then
		BINARIES="${BINARIES} /usr/bin/svn /usr/bin/svnserve"
	fi

	# passwd compatibility
	if has_version "=${CATEGORY}/${PF}[passwd]" ; then
		BINARIES="${BINARIES} /usr/bin/passwd"
	fi

	# quota compatibility
	if has_version "=${CATEGORY}/${PF}[quota]" ; then
		BINARIES="${BINARIES} /usr/bin/quota"
	fi

	# build lib dependencies
	LIB_LIST=$(ldd ${BINARIES} | sed -n 's:.* => \(/[^ ]\+\).*:\1:p' | sort -u)

	# search and add ld*.so
	for LIB in /$(get_libdir)/ld.so /libexec/ld-elf.so /libexec/ld-elf.so.1 \
		/usr/libexec/ld.so /$(get_libdir)/ld-linux*.so.2 /usr/libexec/ld-elf.so.1; do
		[ -f "${LIB}" ] && LIB_LIST="${LIB_LIST} ${LIB}"
	done

	# search and add libnss_*.so
	for LIB in /$(get_libdir)/libnss_{compat,files}*.so.*; do
		[ -f "${LIB}" ] && LIB_LIST="${LIB_LIST} ${LIB}"
	done

	# create base dirs
	if [ ! -d "${myhome}" ]; then
		die "Home '${myhome}' should have been created by acct-user but does not exist."
	else
		einfo "Setting owner for ${myhome}"
		chown 0:0 "${myhome}"
	fi

	if [ ! -d "${myhome}/etc" ]; then
		einfo "Creating ${myhome}/etc"
		install -o0 -g0 -m0755 -d "${myhome}/etc"
	fi

	if [ ! -d "${myhome}/$(get_libdir)" ]; then
		einfo "Creating ${myhome}/$(get_libdir)"
		install -o0 -g0 -m0755 -d "${myhome}/$(get_libdir)"
	fi

	if [ ! -e "${myhome}/lib" ]; then
		einfo "Creating ${myhome}/lib"
		ln -snf $(get_libdir) "${myhome}/lib"
	fi

	if [ ! -d "${myhome}/usr/$(get_libdir)" ]; then
		einfo "Creating ${myhome}/usr/$(get_libdir)"
		install -o0 -g0 -m0755 -d "${myhome}/usr/$(get_libdir)"
	fi

	if [ ! -e "${myhome}/usr/lib" ]; then
		einfo "Creating ${myhome}/usr/lib"
		ln -snf $(get_libdir) "${myhome}/usr/lib"
	fi

	if [ ! -d "${myhome}${mysubdir}" ]; then
		einfo "Creating ${myhome}${mysubdir} directory for uploading files"
		install -o${myuser} -g${myuser} -m0755 -d "${myhome}${mysubdir}"
	fi

	# create /dev/null (Bug 135505)
	if [ ! -e "${myhome}/dev/null" ]; then
		install -o0 -g0 -m0755 -d "${myhome}/dev"
		mknod -m0777 "${myhome}/dev/null" c 1 3
	fi

	# install binaries
	for BIN in ${BINARIES}; do
		einfo "Install ${BIN}"
		install -o0 -g0 -m0755 -d "${myhome}$(dirname ${BIN})"
		if [ "${BIN}" = "/usr/bin/passwd" ]; then  # needs suid
			install -p -o0 -g0 -m04711 "${BIN}" "${myhome}/${BIN}"
		else
			install -p -o0 -g0 -m0755 "${BIN}" "${myhome}/${BIN}"
		fi
	done

	# install libs
	for LIB in ${LIB_LIST}; do
		einfo "Install ${LIB}"
		install -o0 -g0 -m0755 -d "${myhome}$(dirname ${LIB})"
		install -p -o0 -g0 -m0755 "${LIB}" "${myhome}/${LIB}"
	done

	# create ld.so.conf
	einfo "Creating /etc/ld.so.conf"
	for LIB in ${LIB_LIST}; do
		dirname ${LIB}
	done | sort -u | while read DIR; do
		if ! grep 2>/dev/null -q "^${DIR}$" "${myhome}/etc/ld.so.conf"; then
			echo "${DIR}" >> "${myhome}/etc/ld.so.conf"
		fi
	done
	ldconfig -r "${myhome}"

	# update shells
	einfo "Updating /etc/shells"
	grep 2>/dev/null -q "^/usr/bin/scponly$" /etc/shells \
		|| echo "/usr/bin/scponly" >> /etc/shells

	grep 2>/dev/null -q "^/usr/sbin/scponlyc$" /etc/shells \
		|| echo "/usr/sbin/scponlyc" >> /etc/shells

	# create /etc/passwd
	if [ ! -e "${myhome}/etc/passwd" ]; then
		(
			echo "root:x:0:0:root:/:/bin/sh"
			sed -n "s|^\(${myuser}:[^:]*:[^:]*:[^:]*:[^:]*:\).*|\1${mysubdir}:/bin/sh|p" /etc/passwd
		) > "${myhome}/etc/passwd"
	fi

	# create /etc/group
	if [ ! -e "${myhome}/etc/group" ]; then
		(
			echo "root:x:0:"
			sed -n "s|^\(${myuser}:[^:]*:[^:]*:\).*|\1|p" /etc/group
		) > "${myhome}/etc/group"
	fi
}
