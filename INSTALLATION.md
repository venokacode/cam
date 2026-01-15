# EndoscopeViewer - 安装与分发指南

本文档提供了 EndoscopeViewer 应用的构建、测试、安装和分发的完整说明。

## 📋 目录

- [系统要求](#系统要求)
- [快速开始](#快速开始)
- [构建应用](#构建应用)
- [安装应用](#安装应用)
- [分发应用](#分发应用)
- [代码签名](#代码签名)
- [常见问题](#常见问题)

---

## 系统要求

### 开发和构建
- **操作系统**: macOS 12.0 (Monterey) 或更高版本
- **Xcode**: 14.0 或更高版本
- **命令行工具**: Xcode Command Line Tools

### 运行应用
- **操作系统**: macOS 12.0 (Monterey) 或更高版本
- **硬件**: UVC 兼容的摄像头或内窥镜设备
- **权限**: 摄像头访问权限

---

## 快速开始

最快的方式是使用一键构建脚本：

```bash
cd EndoscopeViewer
./quick-build.sh
```

此脚本将：
1. 构建 Release 版本的应用
2. 创建 ZIP 压缩包
3. 生成 DMG 安装文件

完成后，您将获得三种分发格式：
- `build/EndoscopeViewer.app` - 应用程序包
- `build/EndoscopeViewer.zip` - ZIP 归档
- `build/EndoscopeViewer-1.0.dmg` - DMG 安装程序

---

## 构建应用

### 方式 1: 使用构建脚本（推荐）

#### 构建 Release 版本
```bash
./build.sh Release
```

#### 构建 Debug 版本
```bash
./build.sh Debug
```

构建完成后，应用程序将位于：
```
build/EndoscopeViewer.app
```

### 方式 2: 使用 Xcode

1. 打开项目：
   ```bash
   open EndoscopeViewer.xcodeproj
   ```

2. 在 Xcode 中：
   - 选择 **Product → Scheme → EndoscopeViewer**
   - 选择 **Product → Build For → Running** (Debug)
   - 或选择 **Product → Archive** (Release)

3. 构建后的应用位于：
   ```
   ~/Library/Developer/Xcode/DerivedData/EndoscopeViewer-.../Build/Products/
   ```

### 方式 3: 使用命令行

```bash
xcodebuild \
    -project EndoscopeViewer.xcodeproj \
    -scheme EndoscopeViewer \
    -configuration Release \
    clean build
```

---

## 创建分发包

### 创建 DMG 安装程序

```bash
# 首先构建应用
./build.sh Release

# 然后创建 DMG（指定版本号）
./create-dmg.sh 1.0
```

这将创建：
```
build/EndoscopeViewer-1.0.dmg
```

DMG 内容包括：
- EndoscopeViewer.app
- Applications 文件夹的符号链接（用于拖拽安装）
- README.txt 安装说明

### 创建 ZIP 归档

ZIP 归档在 `build.sh` 运行时自动创建：
```
build/EndoscopeViewer.zip
```

---

## 安装应用

### 从 DMG 安装（推荐用户使用）

1. **双击打开** `EndoscopeViewer-1.0.dmg`
2. **拖拽** `EndoscopeViewer.app` 到 `Applications` 文件夹
3. 打开 **Launchpad** 或 **应用程序** 文件夹
4. 启动 **EndoscopeViewer**

### 从 ZIP 安装

1. **解压** `EndoscopeViewer.zip`
2. **移动** `EndoscopeViewer.app` 到 `/Applications` 文件夹
3. 启动应用

### 直接使用（开发测试）

```bash
# 直接运行构建的应用
open build/EndoscopeViewer.app

# 或从命令行启动
./build/EndoscopeViewer.app/Contents/MacOS/EndoscopeViewer
```

---

## 首次启动

### 安全警告处理

由于应用未经过代码签名，macOS 可能会显示安全警告：

#### 方法 1: 右键打开（推荐）
1. **右键点击**（或 Control + 点击）应用图标
2. 选择 **"打开"**
3. 在弹出的对话框中点击 **"打开"**

#### 方法 2: 系统设置
1. 尝试打开应用（会被阻止）
2. 前往 **系统设置 → 隐私与安全性**
3. 在底部找到被阻止的应用
4. 点击 **"仍要打开"**

#### 方法 3: 移除隔离属性（开发者）
```bash
xattr -d com.apple.quarantine build/EndoscopeViewer.app
```

### 授予摄像头权限

首次启动时，应用会请求摄像头权限：
1. 系统会弹出权限请求对话框
2. 点击 **"允许"**
3. 如果误点了拒绝，可以在 **系统设置 → 隐私与安全性 → 摄像头** 中手动启用

---

## 分发应用

### 分发选项

根据您的需求选择分发方式：

| 方式 | 文件 | 适用场景 | 优点 |
|------|------|----------|------|
| **DMG** | EndoscopeViewer-1.0.dmg | 终端用户安装 | 专业、易用、包含说明 |
| **ZIP** | EndoscopeViewer.zip | 快速分享、备份 | 文件小、简单 |
| **.app** | EndoscopeViewer.app | 开发者测试 | 直接使用 |

### 推荐分发流程

1. **构建 Release 版本**：
   ```bash
   ./build.sh Release
   ```

2. **创建 DMG 安装包**：
   ```bash
   ./create-dmg.sh 1.0
   ```

3. **分发 DMG 文件**：
   - 通过邮件发送
   - 上传到文件共享服务
   - 发布到 GitHub Releases
   - 部署到内部服务器

### GitHub Releases 发布

```bash
# 使用 GitHub CLI
gh release create v1.0 \
    build/EndoscopeViewer-1.0.dmg \
    build/EndoscopeViewer.zip \
    --title "EndoscopeViewer v1.0" \
    --notes "Initial release"
```

---

## 代码签名

为了避免安全警告和实现自动更新，建议进行代码签名。

### 前提条件

- Apple Developer 账户（个人或企业）
- 有效的 Developer ID Application 证书

### 签名步骤

#### 1. 在 Xcode 中配置

1. 打开项目设置
2. 选择 **EndoscopeViewer** target
3. 前往 **Signing & Capabilities**
4. 勾选 **"Automatically manage signing"**
5. 选择您的开发团队

#### 2. 使用命令行签名

```bash
# 查看可用的签名身份
security find-identity -v -p codesigning

# 签名应用
codesign --force --deep --sign "Developer ID Application: Your Name" \
    build/EndoscopeViewer.app

# 验证签名
codesign --verify --deep --strict --verbose=2 \
    build/EndoscopeViewer.app

# 检查签名信息
codesign -dv build/EndoscopeViewer.app
```

#### 3. 公证（Notarization）

对于公开分发，需要进行公证：

```bash
# 创建签名的 ZIP
ditto -c -k --keepParent build/EndoscopeViewer.app EndoscopeViewer.zip

# 提交公证
xcrun notarytool submit EndoscopeViewer.zip \
    --apple-id "your@email.com" \
    --password "app-specific-password" \
    --team-id "TEAM_ID" \
    --wait

# 装订公证票据
xcrun stapler staple build/EndoscopeViewer.app
```

### 签名后构建 DMG

签名完成后，重新创建 DMG：
```bash
./create-dmg.sh 1.0
```

---

## 测试安装包

### 测试清单

在分发前，请在干净的环境中测试：

- [ ] DMG 文件可以正常打开
- [ ] 应用可以拖拽到 Applications 文件夹
- [ ] 首次启动显示正确的权限请求
- [ ] 摄像头权限授予后，应用可以正常工作
- [ ] 设备列表正确显示 UVC 设备
- [ ] 格式切换功能正常
- [ ] 拍照和保存功能正常
- [ ] 窗口大小调整正确
- [ ] 应用可以正常退出

### 测试不同 macOS 版本

建议在以下版本上测试：
- macOS 12 (Monterey) - 最低支持版本
- macOS 13 (Ventura)
- macOS 14 (Sonoma)
- macOS 15 (Sequoia) - 最新版本

---

## 常见问题

### Q: 构建失败，提示找不到 Xcode

**A**: 安装 Xcode Command Line Tools：
```bash
xcode-select --install
```

### Q: 应用被 macOS 阻止运行

**A**: 使用右键点击应用，选择"打开"，或使用以下命令：
```bash
xattr -d com.apple.quarantine build/EndoscopeViewer.app
```

### Q: 如何更改应用版本号？

**A**: 编辑 `Info.plist` 中的版本信息：
```xml
<key>CFBundleShortVersionString</key>
<string>1.0</string>
<key>CFBundleVersion</key>
<string>1</string>
```

### Q: 如何减小应用体积？

**A**:
1. 使用 Release 配置构建
2. 启用编译器优化
3. 移除调试符号：
```bash
strip build/EndoscopeViewer.app/Contents/MacOS/EndoscopeViewer
```

### Q: DMG 创建失败

**A**: 确保：
1. 应用已经构建（运行 `./build.sh` 先）
2. 没有同名 DMG 文件被挂载
3. 有足够的磁盘空间

### Q: 如何在其他 Mac 上测试？

**A**:
1. 将 DMG 文件复制到目标 Mac
2. 按照安装步骤操作
3. 或使用 AirDrop、云存储等方式传输

---

## 文件结构说明

构建后的目录结构：

```
EndoscopeViewer/
├── build/                              # 构建输出目录
│   ├── EndoscopeViewer.app            # 应用程序包
│   ├── EndoscopeViewer.zip            # ZIP 归档
│   ├── EndoscopeViewer-1.0.dmg        # DMG 安装程序
│   └── DerivedData/                   # Xcode 构建数据
├── EndoscopeViewer.xcodeproj/         # Xcode 项目
├── EndoscopeViewer/                   # 源代码
├── build.sh                           # 构建脚本
├── create-dmg.sh                      # DMG 创建脚本
├── quick-build.sh                     # 一键构建脚本
├── README.md                          # 用户文档
└── INSTALLATION.md                    # 本文档
```

---

## 自动化构建

### 创建 Makefile

创建 `Makefile` 以简化构建流程：

```makefile
.PHONY: all build dmg clean install test

all: build dmg

build:
	./build.sh Release

dmg: build
	./create-dmg.sh 1.0

clean:
	rm -rf build/

install: build
	cp -R build/EndoscopeViewer.app /Applications/

test:
	open build/EndoscopeViewer.app
```

使用方法：
```bash
make          # 构建并创建 DMG
make build    # 仅构建
make dmg      # 仅创建 DMG
make clean    # 清理
make install  # 安装到 Applications
make test     # 测试运行
```

---

## 持续集成（CI）

### GitHub Actions 示例

创建 `.github/workflows/build.yml`：

```yaml
name: Build macOS App

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: macos-latest

    steps:
    - uses: actions/checkout@v3

    - name: Build application
      run: |
        cd EndoscopeViewer
        ./build.sh Release

    - name: Create DMG
      run: |
        cd EndoscopeViewer
        ./create-dmg.sh ${{ github.ref_name }}

    - name: Upload artifacts
      uses: actions/upload-artifact@v3
      with:
        name: EndoscopeViewer
        path: |
          EndoscopeViewer/build/*.dmg
          EndoscopeViewer/build/*.zip

    - name: Create release
      uses: softprops/action-gh-release@v1
      with:
        files: |
          EndoscopeViewer/build/*.dmg
          EndoscopeViewer/build/*.zip
```

---

## 技术支持

如有问题，请：
1. 查看 [README.md](README.md) 用户文档
2. 查看 [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) 技术文档
3. 提交 Issue 到项目仓库

---

## 版本历史

- **v1.0** (2026-01-15) - 初始发布
  - 基础预览功能
  - 静态图片捕获
  - AMCap 风格格式选择
  - macOS 12+ 支持

---

**构建愉快！** 🚀
