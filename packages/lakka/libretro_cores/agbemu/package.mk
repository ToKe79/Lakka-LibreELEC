PKG_NAME="agbemu"
PKG_VERSION="5618a7f1d7b7aa65d2c194aa896f2a6f57567c50"
PKG_LICENSE="GPL-3.0"
PKG_SITE="https://github.com/jonian/libretro-agbemu"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="An accurate Game Boy Advance Emulator."
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="-f Makefile.libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -v agbemu_libretro.so   ${INSTALL}/usr/lib/libretro/
    cp -v agbemu_libretro.info ${INSTALL}/usr/lib/libretro/
}
