# 变更日志

本文档记录了 LuCI App Fuck PCDN 项目的所有重要变更。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
并且本项目遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [未发布]

### 新增
- 在线域名列表获取功能
- 每次保存设置时自动从 `https://pikachuim.github.io/luci-app-fuck-pcdn/banlist.json` 获取最新域名列表
- 增强的错误处理和日志记录

### 变更
- 更新了所有平台的域名列表，包含更多 PCDN 域名
- 改进了域名获取的超时设置（连接超时 10 秒，总超时 30 秒）
- 优化了备用域名机制，确保在线获取失败时的可靠性

### 修复
- 修复了镜像源 SDK 下载链接问题
- 升级到 OpenWrt 24.10.3，修复了从 23.05.2 版本的兼容性问题
- 更新了构建脚本和 GitHub Actions 中的 SDK URL
- 支持新的 `.zst` 压缩格式和 `armsr/armv8` 架构路径
- 更新 GCC 到 13.3.0 版本，feeds 更新到 `openwrt-24.10` 分支
- 修复了 bcm27xx/bcm2709 架构使用 `musl_eabi` 而非 `musl` 的问题
- 临时移除 telephony feed 以解决构建过程中的包信息收集错误

## [1.0.0] - 2024-01-01

### 新增
- 初始版本发布
- 支持屏蔽 QQ 音乐 PCDN 域名
- 支持屏蔽腾讯视频 PCDN 域名
- 支持屏蔽爱奇艺 PCDN 域名
- 支持屏蔽优酷 PCDN 域名
- 支持屏蔽哔哩哔哩 PCDN 域名
- LuCI Web 界面管理
- UCI 配置系统集成
- 自动化构建和发布流程
- 多架构支持 (x86_64, aarch64, arm, mips, mipsel)

### 技术特性
- 基于 LuCI 框架的现代化 Web 界面
- 使用 ucode 后端脚本处理业务逻辑
- JSON 格式的域名黑名单配置
- 通过修改 /etc/hosts 实现域名屏蔽
- 支持实时启用/禁用功能
- 完整的多语言支持框架

### 安全特性
- 严格的权限控制
- 安全的文件操作
- 输入验证和错误处理

### 构建和部署
- GitHub Actions 自动化构建
- 多架构 IPK 包生成
- 自动化版本发布
- 完整的测试套件

## 版本说明

### 版本号格式
- `MAJOR.MINOR.PATCH` (例如: 1.0.0)
- `MAJOR.MINOR.PATCH-PRERELEASE` (例如: 1.0.0-beta.1)

### 版本类型
- **MAJOR**: 不兼容的 API 变更
- **MINOR**: 向后兼容的功能新增
- **PATCH**: 向后兼容的问题修复
- **PRERELEASE**: 预发布版本

### 支持的架构
- x86_64 (Intel/AMD 64位)
- aarch64_generic (ARM 64位)
- arm_cortex-a9 (ARM Cortex-A9)
- mips_24kc (MIPS 24Kc)
- mipsel_24kc (MIPS 24Kc Little Endian)

### 依赖要求
- OpenWrt 21.02 或更高版本
- LuCI 基础组件
- curl (用于网络请求)
- jsonfilter (用于 JSON 处理)

### 已知问题
- 暂无已知问题

### 计划功能
- 自定义域名黑名单
- 白名单功能
- 统计和监控功能
- 更多流媒体平台支持