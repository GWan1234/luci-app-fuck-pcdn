# See /LICENSE for more information.
# This is free software, licensed under the GNU General Public License v2.

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI Fuck PCDN App
LUCI_DESCRIPTION:=Block PCDN domains for popular video and music streaming services
LUCI_DEPENDS:=+luci-base +curl +jsonfilter
LUCI_PKGARCH:=all

PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKG_LICENSE:=MIT
PKG_MAINTAINER:=OpenWrt Community

include ../../luci.mk

# call BuildPackage - OpenWrt buildroot signature
