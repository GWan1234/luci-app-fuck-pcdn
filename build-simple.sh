#!/bin/bash

# 简化的 IPK 构建脚本 - 无需下载完整 SDK
# 适用于纯 LuCI 应用（无需编译的项目）

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 项目信息
PKG_NAME="luci-app-fuck-pcdn"
PKG_VERSION="1.0.0"
PKG_RELEASE="1"
PKG_ARCH="all"
PKG_MAINTAINER="OpenWrt Community"
PKG_DESCRIPTION="Block PCDN domains for popular video and music streaming services"
PKG_DEPENDS="luci-base, curl, jsonfilter"

# 显示帮助信息
show_help() {
    cat << EOF
简化的 LuCI App Fuck PCDN 构建脚本

用法: $0 [选项]

选项:
  -h, --help          显示此帮助信息
  -v, --version VER   指定版本号 (默认: $PKG_VERSION)
  -o, --output DIR    指定输出目录 (默认: ./dist)

说明:
  此脚本直接打包 IPK 文件，无需下载完整的 OpenWrt SDK。
  适用于纯 LuCI 应用（不包含需要编译的 C/C++ 代码）。

EOF
}

# 解析命令行参数
OUTPUT_DIR="./dist"

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            PKG_VERSION="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        *)
            log_error "未知参数: $1"
            show_help
            exit 1
            ;;
    esac
done

# 创建临时构建目录
BUILD_DIR=$(mktemp -d)
CONTROL_DIR="$BUILD_DIR/CONTROL"
DATA_DIR="$BUILD_DIR/data"

log_info "开始构建 $PKG_NAME v$PKG_VERSION"
log_info "构建目录: $BUILD_DIR"

# 创建目录结构
mkdir -p "$CONTROL_DIR"
mkdir -p "$DATA_DIR"

# 创建 control 文件
cat > "$CONTROL_DIR/control" << EOF
Package: $PKG_NAME
Version: $PKG_VERSION-$PKG_RELEASE
Depends: $PKG_DEPENDS
Section: luci
Category: LuCI
Repository: base
Title: LuCI Fuck PCDN App
Maintainer: $PKG_MAINTAINER
Architecture: $PKG_ARCH
Installed-Size: 1024
Description: $PKG_DESCRIPTION
EOF

# 复制项目文件到数据目录
log_info "复制项目文件..."

# 复制 LuCI 文件
if [ -d "htdocs" ]; then
    mkdir -p "$DATA_DIR/www"
    cp -r htdocs/* "$DATA_DIR/www/"
fi

# 复制根文件系统文件
if [ -d "root" ]; then
    cp -r root/* "$DATA_DIR/"
fi

# 复制翻译文件
if [ -d "po" ]; then
    mkdir -p "$DATA_DIR/usr/lib/lua/luci/i18n"
    # 这里可以添加 po 文件的处理逻辑
    # 简化版本：直接复制 po 文件
    find po -name "*.po" -exec cp {} "$DATA_DIR/usr/lib/lua/luci/i18n/" \;
fi

# 复制数据文件
if [ -f "banlist.json" ]; then
    mkdir -p "$DATA_DIR/etc/luci-app-fuck-pcdn"
    cp banlist.json "$DATA_DIR/etc/luci-app-fuck-pcdn/"
fi

# 设置正确的权限
find "$DATA_DIR" -type f -exec chmod 644 {} \;
find "$DATA_DIR" -type d -exec chmod 755 {} \;

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

# 打包 IPK
IPK_FILE="$OUTPUT_DIR/${PKG_NAME}_${PKG_VERSION}-${PKG_RELEASE}_${PKG_ARCH}.ipk"

log_info "打包 IPK 文件..."

# 创建 data.tar.gz
cd "$DATA_DIR"
tar czf "$BUILD_DIR/data.tar.gz" .

# 创建 control.tar.gz
cd "$CONTROL_DIR"
tar czf "$BUILD_DIR/control.tar.gz" .

# 创建 debian-binary
echo "2.0" > "$BUILD_DIR/debian-binary"

# 创建最终的 IPK 文件
cd "$BUILD_DIR"
tar czf "$IPK_FILE" debian-binary control.tar.gz data.tar.gz

# 清理临时文件
rm -rf "$BUILD_DIR"

# 显示结果
if [ -f "$IPK_FILE" ]; then
    log_success "IPK 文件构建完成: $IPK_FILE"
    log_info "文件大小: $(du -h "$IPK_FILE" | cut -f1)"
    log_info "可以直接在 OpenWrt 设备上使用 'opkg install' 安装此文件"
else
    log_error "IPK 文件构建失败"
    exit 1
fi