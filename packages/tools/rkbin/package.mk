# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="rkbin"
# Version is: Kwiboo/tag:libreelec-4563e24
PKG_VERSION="4563e249a3f47e7fcd47a4c3769b6c05683b6e9d"
PKG_SHA256="0b3479117700bce9afea2110c1f027b626c76d99045802218b35a53606547d60"

if [ "${DEVICE}" = "RK3326" ]; then
  PKG_VERSION="6e5a6beb6508296d03ed2234d945e915ca5c3f6e"
  PKG_SHA256="97ba6c8d546b9ae86d648aff2a27337d559694a590c11a70b0de06c917379af2"
fi

PKG_ARCH="arm aarch64"
PKG_LICENSE="nonfree"
PKG_SITE="https://github.com/rockchip-linux/rkbin"
PKG_URL="https://github.com/rockchip-linux/rkbin/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="rkbin: Rockchip Firmware and Tool Binaries"
PKG_TOOLCHAIN="manual"
