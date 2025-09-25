#!/bin/bash

echo "=== LuCI App Fuck PCDN 测试脚本 ==="
echo

# 检查文件结构
echo "1. 检查文件结构..."
files=(
    "Makefile"
    "htdocs/luci-static/resources/view/fuck-pcdn/form.js"
    "root/usr/share/luci/menu.d/luci-app-fuck-pcdn.json"
    "root/usr/share/rpcd/acl.d/luci-app-fuck-pcdn.json"
    "root/usr/share/rpcd/ucode/fuck-pcdn.uc"
    "root/etc/uci-defaults/80_fuck-pcdn"
    "po/templates/fuck-pcdn.pot"
    "po/zh_Hans/fuck-pcdn.po"
    "banlist.json"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file 存在"
    else
        echo "✗ $file 缺失"
    fi
done

echo
echo "2. 检查 JSON 文件格式..."

# 检查 JSON 文件
json_files=(
    "banlist.json"
    "root/usr/share/luci/menu.d/luci-app-fuck-pcdn.json"
    "root/usr/share/rpcd/acl.d/luci-app-fuck-pcdn.json"
)

for file in "${json_files[@]}"; do
    if python -m json.tool "$file" > /dev/null 2>&1; then
        echo "✓ $file JSON 格式正确"
    else
        echo "✗ $file JSON 格式错误"
    fi
done

echo
echo "3. 检查 JavaScript 语法..."
if node -c htdocs/luci-static/resources/view/fuck-pcdn/form.js 2>/dev/null; then
    echo "✓ form.js JavaScript 语法正确"
else
    echo "✗ form.js JavaScript 语法错误"
fi

echo
echo "4. 检查 Shell 脚本语法..."
if bash -n root/etc/uci-defaults/80_fuck-pcdn 2>/dev/null; then
    echo "✓ UCI 默认配置脚本语法正确"
else
    echo "✗ UCI 默认配置脚本语法错误"
fi

echo
echo "5. 检查域名列表..."
domain_count=$(python -c "
import json
with open('banlist.json', 'r') as f:
    data = json.load(f)
total = sum(len(domains) for domains in data.values())
print(total)
")
echo "✓ 域名列表包含 $domain_count 个域名"

echo
echo "=== 测试完成 ==="