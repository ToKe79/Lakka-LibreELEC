PKG_NAME="slang_shaders"
PKG_VERSION="5fbd6105827fc187b0e1268ca676174c279ec48a"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/libretro/slang-shaders"
PKG_URL="${PKG_SITE}.git"
PKG_LONGDESC="Common Slang shaders for RetroArch"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  make -C ${PKG_BUILD} install INSTALLDIR="${INSTALL}/usr/share/retroarch/shaders/Vulkan-Shaders"
}
