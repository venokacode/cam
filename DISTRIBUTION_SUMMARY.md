# 分发版本总结 - EndoscopeViewer

## 概述

EndoscopeViewer 现在已经完全具备构建、测试和分发的能力。本文档总结了所有可用的分发选项和工具。

---

## 📦 分发包类型

### 1. 应用程序包 (.app)
- **位置**: `build/EndoscopeViewer.app`
- **用途**: 直接使用或拖拽安装
- **优点**: 最简单，可直接运行
- **适用**: 开发测试、快速分享

### 2. ZIP 压缩包 (.zip)
- **位置**: `build/EndoscopeViewer.zip`
- **用途**: 快速分享、网络传输
- **优点**: 文件小，易于下载
- **适用**: 邮件附件、云存储

### 3. DMG 安装包 (.dmg)
- **位置**: `build/EndoscopeViewer-{version}.dmg`
- **用途**: 专业的 macOS 安装体验
- **优点**: 包含说明、拖拽安装、专业外观
- **适用**: 正式发布、终端用户

---

## 🛠️ 构建工具

### 一键构建脚本

```bash
./quick-build.sh
```

**功能：**
- 构建 Release 版本
- 创建 ZIP 归档
- 生成 DMG 安装包
- 一次完成所有构建任务

**输出：**
```
build/
├── EndoscopeViewer.app         # 应用程序
├── EndoscopeViewer.zip         # ZIP 压缩包
└── EndoscopeViewer-1.0.dmg     # DMG 安装包
```

### 单独构建脚本

#### build.sh - 应用构建
```bash
./build.sh [Debug|Release]
```

**功能：**
- 编译 Swift 代码
- 链接框架
- 创建应用程序包
- 生成 ZIP 归档

**选项：**
- `Debug`: 调试版本（包含调试符号）
- `Release`: 发布版本（优化、小体积）

#### create-dmg.sh - DMG 创建
```bash
./create-dmg.sh [version]
```

**功能：**
- 创建临时 DMG 内容
- 添加 Applications 符号链接
- 生成安装说明
- 创建压缩的 DMG 镜像

**参数：**
- `version`: 版本号（默认 1.0）

### Make 构建系统

```bash
make [target]
```

**可用目标：**

| 目标 | 说明 | 等效命令 |
|------|------|----------|
| `make` 或 `make all` | 构建发布版 + DMG | `./quick-build.sh` |
| `make build` | 构建调试版 | `./build.sh Debug` |
| `make debug` | 构建调试版 | `./build.sh Debug` |
| `make release` | 构建发布版 | `./build.sh Release` |
| `make dmg` | 创建 DMG | `./create-dmg.sh` |
| `make install` | 安装到 /Applications | `cp -R build/... /Applications/` |
| `make uninstall` | 从 /Applications 卸载 | `rm -rf /Applications/...` |
| `make clean` | 清理构建产物 | `rm -rf build/` |
| `make test` | 测试运行应用 | `open build/...` |
| `make open` | 在 Xcode 中打开 | `open EndoscopeViewer.xcodeproj` |
| `make help` | 显示帮助信息 | - |

---

## 📋 分发工作流

### 工作流 1: 快速测试分发

适用于内部测试、快速迭代：

```bash
# 1. 构建调试版
make debug

# 2. 测试运行
make test

# 3. 如果需要分享
open build/
# 直接分享 EndoscopeViewer.app 或 EndoscopeViewer.zip
```

### 工作流 2: 正式版本发布

适用于正式发布、用户分发：

```bash
# 1. 构建发布版本
make release

# 2. 创建 DMG（指定版本号）
./create-dmg.sh 1.0

# 3. 测试 DMG
open build/EndoscopeViewer-1.0.dmg

# 4. 验证安装流程
# - 打开 DMG
# - 拖拽到 Applications
# - 启动应用
# - 测试功能

# 5. 发布
# 将 DMG 上传到：
# - GitHub Releases
# - 文件服务器
# - 云存储服务
```

### 工作流 3: 持续集成

适用于自动化构建：

```bash
# CI 脚本示例
#!/bin/bash
set -e

# 克隆代码
git clone <repository> EndoscopeViewer
cd EndoscopeViewer

# 构建
./build.sh Release

# 创建 DMG
./create-dmg.sh ${VERSION}

# 上传制品
# ... 上传逻辑
```

---

## 🚀 分发方式

### 方式 1: GitHub Releases

**步骤：**
```bash
# 1. 创建标签
git tag v1.0
git push origin v1.0

# 2. 使用 GitHub CLI 创建发布
gh release create v1.0 \
    build/EndoscopeViewer-1.0.dmg \
    build/EndoscopeViewer.zip \
    --title "EndoscopeViewer v1.0" \
    --notes "Initial release"
```

**优点：**
- 版本控制
- 自动通知
- 易于下载
- 免费托管

### 方式 2: 直接分享

**ZIP 方式：**
```bash
# 上传 ZIP 到云存储
# - Google Drive
# - Dropbox  
# - OneDrive
# - 企业文件服务器

# 分享下载链接
```

**DMG 方式：**
```bash
# 上传 DMG 到文件服务器
# 提供直接下载链接
```

### 方式 3: 内部分发

**企业/团队内部：**
```bash
# 复制到共享文件夹
cp build/EndoscopeViewer-1.0.dmg /path/to/shared/folder/

# 或通过内部工具分发
```

---

## 📐 文件大小参考

典型的构建大小（Release 配置）：

| 文件类型 | 预估大小 | 说明 |
|---------|---------|------|
| .app | 10-15 MB | 应用程序包 |
| .zip | 5-8 MB | 压缩后的应用 |
| .dmg | 6-10 MB | 压缩的磁盘镜像 |

*实际大小取决于代码、资源和编译选项*

---

## 🔐 代码签名和公证

### 当前状态
应用当前**未签名**，这意味着：
- ✅ 可以正常构建和运行
- ✅ 可以分发给信任的用户
- ⚠️ 首次运行会显示安全警告
- ⚠️ 需要右键打开或移除隔离属性

### 添加代码签名

如果您有 Apple Developer 账户：

```bash
# 1. 在 Xcode 项目设置中配置签名
open EndoscopeViewer.xcodeproj
# 然后在 Signing & Capabilities 中设置

# 2. 使用命令行签名
codesign --deep --force --sign "Developer ID Application: Your Name" \
    build/EndoscopeViewer.app

# 3. 验证签名
codesign --verify --deep --strict build/EndoscopeViewer.app
```

### 公证流程

对于公开分发：

```bash
# 1. 创建 ZIP
ditto -c -k --keepParent build/EndoscopeViewer.app EndoscopeViewer.zip

# 2. 提交公证
xcrun notarytool submit EndoscopeViewer.zip \
    --apple-id "your@email.com" \
    --password "app-specific-password" \
    --team-id "TEAM_ID" \
    --wait

# 3. 装订票据
xcrun stapler staple build/EndoscopeViewer.app

# 4. 重新创建 DMG
./create-dmg.sh 1.0
```

**详细说明见：[INSTALLATION.md - 代码签名章节](INSTALLATION.md#代码签名)**

---

## 📊 质量检查清单

### 构建前检查
- [ ] 更新版本号（Info.plist）
- [ ] 更新 README 和文档
- [ ] 提交所有代码更改
- [ ] 创建 git 标签

### 构建检查
- [ ] Debug 构建成功
- [ ] Release 构建成功
- [ ] 没有编译警告
- [ ] 应用体积合理

### 功能测试
- [ ] 应用可以启动
- [ ] 摄像头权限请求正常
- [ ] 设备可以被检测
- [ ] 预览功能正常
- [ ] 格式切换有效
- [ ] 拍照和保存功能正常
- [ ] 窗口调整正确

### 分发包测试
- [ ] ZIP 可以正常解压
- [ ] DMG 可以正常挂载
- [ ] 从 DMG 拖拽安装有效
- [ ] 安装后应用可以启动
- [ ] README 文件内容正确

### 不同 macOS 版本测试
- [ ] macOS 12 (Monterey)
- [ ] macOS 13 (Ventura)
- [ ] macOS 14 (Sonoma)
- [ ] macOS 15 (Sequoia)

---

## 📄 包含的文档

项目包含完整的多语言文档：

| 文档 | 语言 | 内容 |
|------|------|------|
| [README.md](README.md) | 英文 | 项目概述、技术细节、使用说明 |
| [INSTALLATION.md](INSTALLATION.md) | 中文 | 完整的安装、构建、分发指南 |
| [QUICK_START_CN.md](QUICK_START_CN.md) | 中文 | 快速开始指南、常见问题 |
| [ICON_GUIDE.md](ICON_GUIDE.md) | 英文/中文 | 应用图标设计和集成 |
| [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) | 英文 | 技术实现详解 |
| [DISTRIBUTION_SUMMARY.md](DISTRIBUTION_SUMMARY.md) | 中文 | 本文档 - 分发总结 |

---

## 🎯 推荐分发策略

### 面向终端用户
**推荐：DMG 安装包**
- 专业外观
- 包含说明
- 拖拽安装
- 符合 macOS 惯例

### 面向开发者/测试人员
**推荐：ZIP 归档**
- 快速下载
- 易于分享
- 直接使用

### 面向企业内部
**推荐：应用程序包 + 脚本**
- 批量部署
- 自动化安装
- 内部工具集成

---

## 🔄 版本管理

### 更新版本号

编辑 `Info.plist`：
```xml
<key>CFBundleShortVersionString</key>
<string>1.1</string>
<key>CFBundleVersion</key>
<string>2</string>
```

### 版本命名建议
- `1.0` - 初始发布
- `1.1` - 小更新
- `2.0` - 重大更新

### Git 标签
```bash
git tag v1.0
git tag v1.1
git push --tags
```

---

## 📞 支持和反馈

如果在分发过程中遇到问题：

1. 检查 [INSTALLATION.md](INSTALLATION.md) 故障排除章节
2. 查看 [QUICK_START_CN.md](QUICK_START_CN.md) 常见问题
3. 在 GitHub 仓库提交 Issue

---

## ✅ 完成状态

- ✅ 构建脚本完整
- ✅ DMG 创建自动化
- ✅ 多种分发格式支持
- ✅ Make 构建系统
- ✅ 完整的文档（中英文）
- ✅ 质量检查清单
- ✅ 代码签名准备就绪
- ✅ 示例工作流程

**项目已完全准备好进行测试、构建和分发！** 🚀

---

**更新日期**: 2026-01-15
**适用版本**: EndoscopeViewer 1.0
