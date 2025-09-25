#!/bin/bash

# LuCI App Fuck PCDN 构建脚本
# 用于本地测试构建过程

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"
OPENWRT_VERSION="23.05.2"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# 显示帮助信息
show_help() {
    cat << EOF
LuCI App Fuck PCDN 构建脚本

用法: $0 [选项] [架构]

选项:
  -h, --help          显示此帮助信息
  -c, --clean         清理构建目录
  -v, --version VER   指定 OpenWrt 版本 (默认: $OPENWRT_VERSION)

支持的架构:
  x86_64              x86 64位 (默认)
  aarch64_generic     ARM64 通用
  arm_cortex-a9       ARM Cortex-A9 (树莓派等)
  mips_24kc           MIPS 24Kc (ath79)
  mipsel_24kc         MIPS Little Endian 24Kc (ramips)
  all                 构建所有架构

示例:
  $0                  # 构建 x86_64 架构
  $0 mips_24kc        # 构建 MIPS 架构
  $0 all              # 构建所有架构
  $0 -c               # 清理构建目录
EOF
}

# 清理构建目录
clean_build() {
    log_info "清理构建目录..."
    rm -rf "$BUILD_DIR"
    log_success "构建目录已清理"
}

# 获取 SDK URL
get_sdk_url() {
    local arch=$1
    local sdk_path=""
    
    case $arch in
        "x86_64")
            sdk_path="x86/64"
            ;;
        "aarch64_generic")
            sdk_path="armvirt/64"
            ;;
        "arm_cortex-a9")
            sdk_path="bcm27xx/bcm2709"
            ;;
        "mips_24kc")
            sdk_path="ath79/generic"
            ;;
        "mipsel_24kc")
            sdk_path="ramips/mt7621"
            ;;
        *)
            log_error "不支持的架构: $arch"
            return 1
            ;;
    esac
    
    echo "https://downloads.openwrt.org/releases/$OPENWRT_VERSION/targets/$sdk_path/openwrt-sdk-$OPENWRT_VERSION-${sdk_path}_gcc-12.3.0_musl.Linux-x86_64.tar.xz"
}

# 下载并设置 SDK
setup_sdk() {
    local arch=$1
    local sdk_url=$(get_sdk_url "$arch")
    local sdk_dir="$BUILD_DIR/sdk-$arch"
    
    log_info "为 $arch 架构设置 SDK..."
    
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    
    # 下载 SDK
    if [ ! -f "sdk-$arch.tar.xz" ]; then
        log_info "下载 SDK: $sdk_url"
        wget -O "sdk-$arch.tar.xz" "$sdk_url" || {
            log_error "SDK 下载失败"
            return 1
        }
    else
        log_info "使用缓存的 SDK"
    fi
    
    # 解压 SDK
    if [ ! -d "$sdk_dir" ]; then
        log_info "解压 SDK..."
        tar -xf "sdk-$arch.tar.xz"
        mv openwrt-sdk-* "$sdk_dir"
    fi
    
    cd "$sdk_dir"
    
    # 设置 feeds
    log_info "配置 feeds..."
    cat > feeds.conf << 'EOF'
src-git packages https://git.openwrt.org/feed/packages.git^openwrt-23.05
src-git luci https://git.openwrt.org/project/luci.git^openwrt-23.05
src-git routing https://git.openwrt.org/feed/routing.git^openwrt-23.05
src-git telephony https://git.openwrt.org/feed/telephony.git^openwrt-23.05
EOF
    
    ./scripts/feeds update -a
    ./scripts/feeds install -a
    
    log_success "SDK 设置完成"
}

# 构建包
build_package() {
    local arch=$1
    local sdk_dir="$BUILD_DIR/sdk-$arch"
    local package_dir="$sdk_dir/package/luci-app-fuck-pcdn"
    
    log_info "为 $arch 架构构建包..."
    
    cd "$sdk_dir"
    
    # 复制包文件
    log_info "复制包文件..."
    rm -rf "$package_dir"
    mkdir -p "$package_dir"
    
    # 复制所有文件，排除构建目录和 git 目录
    rsync -av --exclude='.git' --exclude='build' --exclude='.github' \
        "$SCRIPT_DIR/" "$package_dir/"
    
    # 配置构建
    log_info "配置构建..."
    make defconfig
    echo "CONFIG_PACKAGE_luci-app-fuck-pcdn=m" >> .config
    make defconfig
    
    # 构建
    log_info "开始构建..."
    make package/luci-app-fuck-pcdn/compile V=s || {
        log_error "构建失败"
        return 1
    }
    
    # 查找并复制 IPK
    local ipk_file=$(find bin/ -name "luci-app-fuck-pcdn*.ipk" | head -1)
    if [ -n "$ipk_file" ]; then
        cp "$ipk_file" "$BUILD_DIR/luci-app-fuck-pcdn_$arch.ipk"
        log_success "IPK 已生成: $BUILD_DIR/luci-app-fuck-pcdn_$arch.ipk"
    else
        log_error "未找到 IPK 文件"
        return 1
    fi
}

# 主函数
main() {
    local arch="x86_64"
    local clean_only=false
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -c|--clean)
                clean_only=true
                shift
                ;;
            -v|--version)
                OPENWRT_VERSION="$2"
                shift 2
                ;;
            all)
                arch="all"
                shift
                ;;
            x86_64|aarch64_generic|arm_cortex-a9|mips_24kc|mipsel_24kc)
                arch="$1"
                shift
                ;;
            *)
                log_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 如果只是清理
    if [ "$clean_only" = true ]; then
        clean_build
        exit 0
    fi
    
    log_info "开始构建 LuCI App Fuck PCDN"
    log_info "OpenWrt 版本: $OPENWRT_VERSION"
    log_info "目标架构: $arch"
    
    # 检查依赖
    for cmd in wget tar rsync make; do
        if ! command -v $cmd &> /dev/null; then
            log_error "缺少依赖: $cmd"
            exit 1
        fi
    done
    
    if [ "$arch" = "all" ]; then
        # 构建所有架构
        local archs=("x86_64" "aarch64_generic" "arm_cortex-a9" "mips_24kc" "mipsel_24kc")
        for target_arch in "${archs[@]}"; do
            log_info "构建架构: $target_arch"
            setup_sdk "$target_arch" && build_package "$target_arch"
        done
    else
        # 构建单个架构
        setup_sdk "$arch" && build_package "$arch"
    fi
    
    # 生成校验和
    cd "$BUILD_DIR"
    if ls luci-app-fuck-pcdn_*.ipk 1> /dev/null 2>&1; then
        log_info "生成校验和..."
        sha256sum luci-app-fuck-pcdn_*.ipk > SHA256SUMS
        log_success "构建完成！"
        echo
        log_info "生成的文件:"
        ls -la luci-app-fuck-pcdn_*.ipk SHA256SUMS
    else
        log_error "没有找到生成的 IPK 文件"
        exit 1
    fi
}

# 运行主函数
main "$@"