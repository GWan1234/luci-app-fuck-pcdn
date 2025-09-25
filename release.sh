#!/bin/bash

# LuCI App Fuck PCDN 发布脚本
# 用于自动化版本发布流程

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
LuCI App Fuck PCDN 发布脚本

用法: $0 [选项] <版本号>

选项:
  -h, --help          显示此帮助信息
  -d, --dry-run       预览模式，不实际创建标签
  -f, --force         强制覆盖已存在的标签

版本号格式:
  v1.0.0              标准版本号
  v1.0.0-beta.1       预发布版本
  v1.0.0-rc.1         候选版本

示例:
  $0 v1.0.0           # 发布 v1.0.0 版本
  $0 -d v1.1.0        # 预览 v1.1.0 版本发布
  $0 -f v1.0.1        # 强制发布 v1.0.1 版本
EOF
}

# 验证版本号格式
validate_version() {
    local version=$1
    if [[ ! $version =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?$ ]]; then
        log_error "无效的版本号格式: $version"
        log_info "正确格式: v1.0.0 或 v1.0.0-beta.1"
        return 1
    fi
}

# 检查工作目录状态
check_git_status() {
    if ! git diff-index --quiet HEAD --; then
        log_error "工作目录有未提交的更改"
        log_info "请先提交或暂存所有更改"
        return 1
    fi
    
    local branch=$(git rev-parse --abbrev-ref HEAD)
    if [ "$branch" != "main" ] && [ "$branch" != "master" ]; then
        log_warning "当前不在主分支 ($branch)"
        read -p "是否继续? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "发布已取消"
            return 1
        fi
    fi
}

# 检查标签是否存在
check_tag_exists() {
    local version=$1
    local force=$2
    
    if git tag -l | grep -q "^$version$"; then
        if [ "$force" = true ]; then
            log_warning "标签 $version 已存在，将被覆盖"
            git tag -d "$version"
            git push origin ":refs/tags/$version" 2>/dev/null || true
        else
            log_error "标签 $version 已存在"
            log_info "使用 -f 选项强制覆盖"
            return 1
        fi
    fi
}

# 更新版本信息
update_version_info() {
    local version=$1
    
    log_info "更新版本信息..."
    
    # 更新 Makefile 中的版本信息
    if [ -f "Makefile" ]; then
        sed -i.bak "s/PKG_VERSION:=.*/PKG_VERSION:=${version#v}/" Makefile
        sed -i.bak "s/PKG_RELEASE:=.*/PKG_RELEASE:=1/" Makefile
        rm -f Makefile.bak
        log_info "已更新 Makefile 版本信息"
    fi
    
    # 更新 README.md 中的版本信息
    if [ -f "README.md" ]; then
        sed -i.bak "s/版本: v[0-9.]*/版本: $version/" README.md
        rm -f README.md.bak
        log_info "已更新 README.md 版本信息"
    fi
}

# 生成更新日志
generate_changelog() {
    local version=$1
    local changelog_file="CHANGELOG_$version.md"
    
    log_info "生成更新日志..."
    
    # 获取上一个标签
    local last_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
    
    cat > "$changelog_file" << EOF
# $version 更新日志

## 新增功能
- 

## 改进优化
- 

## 问题修复
- 

## 其他变更
- 

EOF

    if [ -n "$last_tag" ]; then
        echo "## 提交记录" >> "$changelog_file"
        echo "" >> "$changelog_file"
        git log --oneline "$last_tag..HEAD" | sed 's/^/- /' >> "$changelog_file"
    fi
    
    log_info "更新日志已生成: $changelog_file"
    log_info "请编辑此文件以添加详细的更新说明"
    
    # 提示用户编辑更新日志
    read -p "是否现在编辑更新日志? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        ${EDITOR:-nano} "$changelog_file"
    fi
}

# 创建发布
create_release() {
    local version=$1
    local dry_run=$2
    
    log_info "创建发布 $version..."
    
    if [ "$dry_run" = true ]; then
        log_info "[预览模式] 将执行以下操作:"
        log_info "1. 提交版本更新"
        log_info "2. 创建标签: $version"
        log_info "3. 推送到远程仓库"
        log_info "4. 触发 GitHub Actions 构建"
        return 0
    fi
    
    # 提交版本更新
    if git diff-index --quiet HEAD --; then
        log_info "没有需要提交的更改"
    else
        git add .
        git commit -m "chore: bump version to $version"
        log_info "已提交版本更新"
    fi
    
    # 创建标签
    git tag -a "$version" -m "Release $version"
    log_success "已创建标签: $version"
    
    # 推送到远程仓库
    git push origin HEAD
    git push origin "$version"
    log_success "已推送到远程仓库"
    
    log_success "发布 $version 已创建！"
    log_info "GitHub Actions 将自动构建并发布 IPK 包"
    log_info "请访问 GitHub Releases 页面查看构建进度"
}

# 主函数
main() {
    local version=""
    local dry_run=false
    local force=false
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -d|--dry-run)
                dry_run=true
                shift
                ;;
            -f|--force)
                force=true
                shift
                ;;
            v*)
                version="$1"
                shift
                ;;
            *)
                log_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 检查版本号
    if [ -z "$version" ]; then
        log_error "请指定版本号"
        show_help
        exit 1
    fi
    
    # 验证版本号格式
    validate_version "$version" || exit 1
    
    # 检查 git 状态
    check_git_status || exit 1
    
    # 检查标签是否存在
    check_tag_exists "$version" "$force" || exit 1
    
    log_info "准备发布版本: $version"
    
    if [ "$dry_run" = false ]; then
        # 确认发布
        read -p "确认发布版本 $version? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "发布已取消"
            exit 0
        fi
        
        # 更新版本信息
        update_version_info "$version"
        
        # 生成更新日志
        generate_changelog "$version"
    fi
    
    # 创建发布
    create_release "$version" "$dry_run"
}

# 检查是否在 git 仓库中
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    log_error "当前目录不是 git 仓库"
    exit 1
fi

# 运行主函数
main "$@"