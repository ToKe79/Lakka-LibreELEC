PKG_NAME="rustation"
PKG_VERSION="db799c549571a49f4f5a43306aff730c599587b1"
PKG_LICENSE="GPL-2.0"
PKG_SITE="https://github.com/simias/rustation-libretro"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain cargo:host"
PKG_LONGDESC="Libretro implementation for the rustation emulator"
PKG_TOOLCHAIN="manual"

if [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL}"
fi

if [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

make_target() {
	 cargo build --release --target ${TARGET_NAME}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -v ${PKG_BUILD}/.${TARGET_NAME}/target/${TARGET_NAME}/release/librustation_libretro.so ${INSTALL}/usr/lib/libretro/rustation_libretro.so
}
