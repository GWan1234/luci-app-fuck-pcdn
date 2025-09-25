#!/bin/bash

# 测试在线域名获取功能
echo "=== 测试在线域名获取功能 ==="

API_URL="https://pikachuim.github.io/luci-app-fuck-pcdn/banlist.json"

echo "正在从 $API_URL 获取域名列表..."

# 测试 curl 获取
if command -v curl >/dev/null 2>&1; then
    echo "使用 curl 测试..."
    curl -s --connect-timeout 10 --max-time 30 "$API_URL" | head -20
    echo ""
    echo "curl 退出码: $?"
else
    echo "curl 命令不可用"
fi

# 测试 wget 获取（备用方案）
if command -v wget >/dev/null 2>&1; then
    echo "使用 wget 测试..."
    wget -q -O - --timeout=30 "$API_URL" | head -20
    echo ""
    echo "wget 退出码: $?"
else
    echo "wget 命令不可用"
fi

echo ""
echo "=== 本地 banlist.json 验证 ==="
if [ -f "banlist.json" ]; then
    echo "本地文件存在，验证 JSON 格式..."
    if command -v python >/dev/null 2>&1; then
        python -m json.tool banlist.json >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "✓ 本地 JSON 格式正确"
            echo "域名统计："
            python -c "
import json
with open('banlist.json', 'r') as f:
    data = json.load(f)
    for platform, domains in data.items():
        print(f'  {platform}: {len(domains)} 个域名')
"
        else
            echo "✗ 本地 JSON 格式错误"
        fi
    else
        echo "python 不可用，跳过 JSON 验证"
    fi
else
    echo "✗ 本地 banlist.json 文件不存在"
fi

echo ""
echo "=== 测试完成 ==="