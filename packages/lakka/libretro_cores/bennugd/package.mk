PKG_NAME="bennugd"
PKG_VERSION="a78319991d62520bed4e873d3538657ad0ae2ca7"
PKG_SITE="https://github.com/diekleinekuh/BennuGD_libretro"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A wrapper around BennuGD to turn it into a libretro core."
PKG_TOOLCHAIN="cmake"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -v bin/MinSizeRel/bennugd_libretro.so ${INSTALL}/usr/lib/libretro/
}
