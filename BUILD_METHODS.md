# 构建方式说明

本项目提供两种构建 IPK 包的方式，您可以根据需要选择：

## 方式一：简化构建（推荐）

### 特点
- ✅ **快速**：无需下载 OpenWrt SDK（约 100MB+）
- ✅ **轻量**：只需要基本的构建工具
- ✅ **适用**：适合纯 LuCI 应用（本项目的情况）
- ✅ **高效**：构建时间从 5-10 分钟缩短到 30 秒内

### 使用方法

#### 本地构建
```bash
# 使用简化构建脚本
chmod +x build-simple.sh
./build-simple.sh

# 指定版本和输出目录
./build-simple.sh -v 1.0.1 -o release
```

#### GitHub Actions
使用 `.github/workflows/build-simple.yml` 工作流，会自动：
- 构建 IPK 包
- 上传构建产物
- 创建 GitHub Release

### 原理
直接将项目文件按照 OpenWrt IPK 格式打包：
1. 创建 `control` 文件（包信息）
2. 打包项目文件为 `data.tar.gz`
3. 打包控制信息为 `control.tar.gz`
4. 组合成最终的 `.ipk` 文件

---

## 方式二：完整 SDK 构建

### 特点
- ⚠️ **完整**：使用官方 OpenWrt SDK 构建环境
- ⚠️ **重量**：需要下载完整 SDK（100MB+）
- ⚠️ **慢速**：构建时间较长
- ✅ **兼容**：与官方构建流程完全一致

### 使用方法

#### 本地构建
```bash
# 使用完整构建脚本
chmod +x build.sh
./build.sh x86_64
```

#### GitHub Actions
使用 `.github/workflows/build-release.yml` 工作流。

### 适用场景
- 包含需要编译的 C/C++ 代码
- 需要与特定 OpenWrt 版本严格兼容
- 官方发布流程

---

## 推荐选择

### 对于本项目（LuCI App Fuck PCDN）
**推荐使用方式一（简化构建）**，因为：

1. **项目特性**：纯 LuCI 应用，包含：
   - Lua 脚本
   - HTML/CSS/JS 文件
   - 翻译文件
   - 配置文件
   - JSON 数据文件

2. **无编译需求**：所有文件都是文本文件，无需编译

3. **效率优势**：
   - 构建时间：30秒 vs 5-10分钟
   - 资源消耗：几MB vs 100MB+
   - 维护成本：低 vs 高

### 何时使用完整 SDK 构建
- 项目包含 C/C++ 源代码
- 需要链接系统库
- 需要交叉编译
- 官方软件包发布

---

## 文件对比

| 文件 | 简化构建 | 完整构建 | 说明 |
|------|----------|----------|------|
| `build-simple.sh` | ✅ | ❌ | 简化构建脚本 |
| `build.sh` | ❌ | ✅ | 完整构建脚本 |
| `.github/workflows/build-simple.yml` | ✅ | ❌ | 简化 CI/CD |
| `.github/workflows/build-release.yml` | ❌ | ✅ | 完整 CI/CD |

---

## 迁移建议

如果您当前使用完整构建方式，可以考虑迁移到简化构建：

1. **测试简化构建**：
   ```bash
   ./build-simple.sh -o test
   ```

2. **验证 IPK 包**：
   ```bash
   # 检查包内容
   ar -t test/luci-app-fuck-pcdn_*.ipk
   
   # 解压查看
   mkdir temp && cd temp
   ar -x ../test/luci-app-fuck-pcdn_*.ipk
   tar -tf data.tar.gz
   ```

3. **切换 CI/CD**：
   - 禁用 `build-release.yml`
   - 启用 `build-simple.yml`

4. **更新文档**：
   - 更新 README.md 中的构建说明
   - 更新 BUILDING.md

这样可以显著提高开发效率，减少资源消耗。