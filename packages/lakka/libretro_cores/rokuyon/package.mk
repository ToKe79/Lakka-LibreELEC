PKG_NAME="rokuyon"
PKG_VERSION="26b2d9cffa71fe4380bc8f633790d9741c91265b"
PKG_ARCH="aarch64 x86_64"
PKG_LICENSE="GPL-3.0"
PKG_SITE="https://github.com/jonian/libretro-rokuyon"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Unofficial libretro port of the Rokuyon n64 emulator"
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="libretro"

if [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL}"
fi

if [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -v rokuyon_libretro.so   ${INSTALL}/usr/lib/libretro/
    cp -v rokuyon_libretro.info ${INSTALL}/usr/lib/libretro/
}
