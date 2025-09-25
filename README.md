# LuCI App Fuck PCDN

[![Build Status](https://github.com/pikachuim/luci-app-fuck-pcdn/workflows/Build%20and%20Release/badge.svg)](https://github.com/pikachuim/luci-app-fuck-pcdn/actions)
[![Release](https://img.shields.io/github/v/release/pikachuim/luci-app-fuck-pcdn)](https://github.com/pikachuim/luci-app-fuck-pcdn/releases)
[![License](https://img.shields.io/github/license/pikachuim/luci-app-fuck-pcdn)](LICENSE)
[![OpenWrt](https://img.shields.io/badge/OpenWrt-21.02%2B-blue)](https://openwrt.org/)

一个用于屏蔽主流视频和音乐平台 PCDN 域名的 OpenWrt LuCI 应用。

## 功能特性

- 🚫 屏蔽主流平台的 PCDN 域名，强制使用原始 CDN
- 🎵 支持 QQ音乐、腾讯视频、爱奇艺、优酷视频、Bilibili
- 🔧 简单易用的 Web 界面配置
- 🌐 支持从远程 JSON API 获取最新域名列表
- 💾 自动备份和恢复 hosts 文件
- 🔄 实时应用设置，无需重启

## 支持的平台

- **QQ音乐** - 屏蔽 QQ音乐的 PCDN 域名
- **腾讯视频** - 屏蔽腾讯视频的 PCDN 域名  
- **爱奇艺** - 屏蔽爱奇艺的 PCDN 域名
- **优酷视频** - 屏蔽优酷视频的 PCDN 域名
- **Bilibili** - 屏蔽 Bilibili 的 PCDN 域名

## 安装方法

### 下载预编译包 (推荐)

从 [Releases](https://github.com/pikachuim/luci-app-fuck-pcdn/releases) 页面下载适合您设备架构的 IPK 包：

- `luci-app-fuck-pcdn_1.0.0-1_all_x86_64.ipk` - x86_64 架构
- `luci-app-fuck-pcdn_1.0.0-1_all_aarch64.ipk` - ARM64 架构
- `luci-app-fuck-pcdn_1.0.0-1_all_arm.ipk` - ARM 架构
- `luci-app-fuck-pcdn_1.0.0-1_all_mips.ipk` - MIPS 架构
- `luci-app-fuck-pcdn_1.0.0-1_all_mipsel.ipk` - MIPS Little Endian 架构

然后通过 OpenWrt 管理界面或命令行安装：

```bash
# 通过 Web 界面：系统 -> 软件包 -> 上传软件包
# 或通过命令行：
opkg install luci-app-fuck-pcdn_*.ipk
```

### 从源码编译

#### 快速构建 (推荐)

```bash
# 克隆仓库
git clone https://github.com/pikachuim/luci-app-fuck-pcdn.git
cd luci-app-fuck-pcdn

# 快速构建 IPK 包（无需下载 SDK）
chmod +x build-simple.sh
./build-simple.sh

# 指定版本和输出目录
./build-simple.sh -v 1.0.1 -o release
```

#### 完整 SDK 构建

```bash
# 使用完整 OpenWrt SDK 构建（较慢但更兼容）
./build.sh all

# 或构建特定架构
./build.sh x86_64
```

> **💡 提示**: 对于本项目（纯 LuCI 应用），推荐使用快速构建方式。详见 [BUILD_METHODS.md](BUILD_METHODS.md)

#### 集成到 OpenWrt 构建系统

1. 将此应用放置在 OpenWrt 构建系统的 `feeds/luci/applications/` 目录下
2. 运行 `make menuconfig` 并选择 `LuCI -> Applications -> luci-app-fuck-pcdn`
3. 编译并安装到设备

### 手动安装

```sh
# 复制文件到设备
scp -r root/* root@192.168.1.1:/
scp -r htdocs/* root@192.168.1.1:/www/

# 执行 UCI 默认配置脚本
ssh root@192.168.1.1 "sh /etc/uci-defaults/80_fuck-pcdn"

# 重启 rpcd 服务
ssh root@192.168.1.1 "/etc/init.d/rpcd restart"
```

## 使用方法

1. 在 OpenWrt 管理界面中，导航到 `服务 -> PCDN屏蔽器`
2. 启用插件功能
3. 选择需要屏蔽的平台（可多选）
4. 点击保存并应用设置

## 工作原理

应用通过以下方式工作：

1. **在线域名获取**: 每次保存设置时，自动从 `https://pikachuim.github.io/luci-app-fuck-pcdn/banlist.json` 获取最新的域名列表
2. **备用域名**: 如果在线获取失败（网络问题等），自动使用内置的备用域名列表
3. **Hosts 修改**: 将选中平台的 PCDN 域名添加到 `/etc/hosts` 文件，指向 `127.0.0.1`
4. **服务重启**: 自动重启 dnsmasq 服务使设置生效
5. **备份恢复**: 自动备份原始 hosts 文件，支持恢复

## 配置文件

应用使用 UCI 配置系统，配置文件位于 `/etc/config/fuck-pcdn`：

```
config settings 'settings'
    option enabled '0'

config platform 'platform'
    option qq_music '0'
    option tencent_video '0'
    option iqiyi '0'
    option youku '0'
    option bilibili '0'
```

## 域名列表格式

应用会自动从 `https://pikachuim.github.io/luci-app-fuck-pcdn/banlist.json` 获取最新的域名列表。JSON 格式如下：

```json
{
  "qq_music": [
    "musicps.p2p.qq.com",
    "p.tencentmusic.com",
    "twns.p2ptun.qq.com",
    "p2p.music.qq.com",
    "ws.stream.qqmusic.qq.com"
  ],
  "tencent_video": [
    "p2p.video.qq.com",
    "livep2p.video.qq.com",
    "btrace.video.qq.com",
    "vd.l.qq.com",
    "livew.l.qq.com"
  ],
  "iqiyi": [
    "p2p.iqiyi.com",
    "p2p-live.iqiyi.com",
    "msg.71.am",
    "msg.qy.net",
    "cupid.iqiyi.com"
  ],
  "youku": [
    "p2p.youku.com",
    "p2p-live.youku.com",
    "hudong.pl.youku.com",
    "lstat.youku.com",
    "atm.youku.com"
  ],
  "bilibili": [
    "p2p.biliapi.net",
    "p2p.bilibili.com",
    "livep2p.bilibili.com",
    "data.bilibili.com",
    "cm.bilibili.com"
  ]
}
```

## 文件结构

```
.
├── Makefile                                    # 包定义文件
├── README.md                                   # 说明文档
├── htdocs/
│   └── luci-static/
│       └── resources/
│           └── view/
│               └── fuck-pcdn/
│                   └── form.js                 # 前端界面
├── po/                                         # 多语言支持
│   ├── templates/
│   │   └── fuck-pcdn.pot                      # 翻译模板
│   └── zh_Hans/
│       └── fuck-pcdn.po                       # 中文翻译
└── root/
    ├── etc/
    │   └── uci-defaults/
    │       └── 80_fuck-pcdn                   # UCI 默认配置
    └── usr/
        └── share/
            ├── luci/
            │   └── menu.d/
            │       └── luci-app-fuck-pcdn.json # 菜单配置
            └── rpcd/
                ├── acl.d/
                │   └── luci-app-fuck-pcdn.json # ACL 权限
                └── ucode/
                    └── fuck-pcdn.uc           # 后端逻辑
```

## 注意事项

- 屏蔽 PCDN 可能会影响视频加载速度，请根据网络情况选择使用
- 应用会自动备份 hosts 文件到 `/etc/hosts.fuck-pcdn.bak`
- 如需恢复原始设置，可以禁用插件或手动恢复备份文件
- 安装后需要重新登录 LuCI 界面以刷新缓存

## 开发

### 本地开发环境

```bash
# 克隆仓库
git clone https://github.com/pikachuim/luci-app-fuck-pcdn.git
cd luci-app-fuck-pcdn

# 运行测试
./test.sh

# 本地构建
./build.sh x86_64
```

### 发布新版本

```bash
# 使用发布脚本
./release.sh v1.1.0

# 或手动创建标签
git tag v1.1.0
git push origin v1.1.0
```

GitHub Actions 将自动构建并发布新版本。

### 项目结构

详细的项目结构说明请参考 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 贡献

我们欢迎各种形式的贡献！请阅读 [CONTRIBUTING.md](CONTRIBUTING.md) 了解如何参与项目开发。

### 快速开始

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

### 报告问题

如果您发现了 Bug 或有功能建议，请在 [Issues](https://github.com/pikachuim/luci-app-fuck-pcdn/issues) 页面创建新的 Issue。

## 变更日志

详细的变更记录请查看 [CHANGELOG.md](CHANGELOG.md)。

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 作者

- **OpenWrt Community** - 初始开发
- **Pikachu Ren** - 原始概念和设计

查看 [贡献者列表](https://github.com/pikachuim/luci-app-fuck-pcdn/contributors) 了解所有参与此项目的开发者。

## 致谢

- OpenWrt 项目团队
- LuCI 框架开发者
- 所有贡献者和用户
