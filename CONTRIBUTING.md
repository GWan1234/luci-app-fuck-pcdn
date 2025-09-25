# 贡献指南

感谢您对 LuCI App Fuck PCDN 项目的关注！我们欢迎各种形式的贡献。

## 如何贡献

### 报告 Bug

如果您发现了 Bug，请：

1. 检查 [Issues](https://github.com/pikachuim/luci-app-fuck-pcdn/issues) 确保该问题尚未被报告
2. 使用 Bug 报告模板创建新的 Issue
3. 提供详细的复现步骤和环境信息

### 建议新功能

如果您有新功能的想法：

1. 检查现有的 Issues 和 Pull Requests
2. 使用功能请求模板创建新的 Issue
3. 详细描述功能的用途和实现方式

### 提交代码

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交您的更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 开发环境设置

### 前置要求

- Linux 或 macOS 开发环境
- Git
- wget, tar, rsync, make
- Node.js (用于 JavaScript 语法检查)

### 本地构建

1. 克隆仓库：
```bash
git clone https://github.com/pikachuim/luci-app-fuck-pcdn.git
cd luci-app-fuck-pcdn
```

2. 运行构建脚本：
```bash
chmod +x build.sh
./build.sh --help  # 查看帮助
./build.sh x86_64  # 构建 x86_64 架构
```

3. 测试构建结果：
```bash
ls build/luci-app-fuck-pcdn_*.ipk
```

## 代码规范

### JavaScript

- 使用严格模式 (`'use strict';`)
- 遵循 LuCI 框架的编码规范
- 使用有意义的变量和函数名
- 添加必要的注释

### Shell 脚本

- 使用 `#!/bin/bash` 作为 shebang
- 使用 `set -e` 启用错误退出
- 为复杂逻辑添加注释
- 使用有意义的变量名

### ucode 脚本

- 遵循 OpenWrt ucode 编码规范
- 添加错误处理
- 使用适当的日志记录

## 测试

### 语法检查

```bash
# JavaScript 语法检查
node -c htdocs/luci-static/resources/view/fuck-pcdn/form.js

# JSON 格式检查
python -m json.tool banlist.json

# Shell 脚本语法检查
bash -n build.sh
bash -n release.sh
```

### 功能测试

1. 在 OpenWrt 环境中安装测试
2. 验证 Web 界面功能
3. 测试域名屏蔽效果
4. 检查日志输出

## 发布流程

### 版本号规范

使用语义化版本号：
- `v1.0.0` - 主要版本
- `v1.1.0` - 次要版本（新功能）
- `v1.0.1` - 补丁版本（Bug 修复）
- `v1.0.0-beta.1` - 预发布版本

### 发布步骤

1. 更新版本信息
2. 运行发布脚本：
```bash
chmod +x release.sh
./release.sh v1.0.0
```

3. GitHub Actions 将自动构建并发布

## 项目结构

```
luci-app-fuck-pcdn/
├── .github/                    # GitHub 配置
│   ├── workflows/             # GitHub Actions
│   └── ISSUE_TEMPLATE/        # Issue 模板
├── htdocs/                    # 前端文件
├── po/                        # 多语言文件
├── root/                      # 系统文件
├── build.sh                   # 构建脚本
├── release.sh                 # 发布脚本
├── Makefile                   # 包构建配置
└── README.md                  # 项目说明
```

## 联系方式

如果您有任何问题，可以通过以下方式联系：

- 创建 Issue
- 发起 Discussion
- 发送邮件到 [your-email@example.com]

## 许可证

通过贡献代码，您同意您的贡献将在 MIT 许可证下授权。