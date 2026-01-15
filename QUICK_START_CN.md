# EndoscopeViewer - 快速开始指南 🚀

一款专为 macOS 设计的 UVC 牙科内窥镜查看器应用程序。

---

## 📦 立即安装使用

### 方式 1: 下载 DMG 安装（推荐）

1. 下载 `EndoscopeViewer-1.0.dmg`
2. 双击打开 DMG 文件
3. 将 `EndoscopeViewer.app` 拖到 `Applications` 文件夹
4. 完成！

### 方式 2: 从源代码构建

**一键构建：**

```bash
cd EndoscopeViewer
./quick-build.sh
```

输入版本号（默认 1.0），等待构建完成。

**构建产物：**
- `build/EndoscopeViewer.app` - 应用程序
- `build/EndoscopeViewer.zip` - ZIP 压缩包
- `build/EndoscopeViewer-1.0.dmg` - DMG 安装包

---

## 🎯 首次运行

### 1. 打开应用

**如果从 DMG 安装：**
- 在 Launchpad 或应用程序文件夹中找到 EndoscopeViewer
- 点击打开

**如果遇到安全警告：**
- 右键点击应用图标
- 选择"打开"
- 在弹窗中再次点击"打开"

**或者使用命令：**
```bash
xattr -d com.apple.quarantine /Applications/EndoscopeViewer.app
```

### 2. 授权摄像头权限

首次启动时会弹出权限请求：
- 点击"允许"即可
- 如果误点了拒绝，前往：**系统设置 → 隐私与安全性 → 摄像头**

### 3. 连接设备

- 通过 USB 连接您的内窥镜设备
- 设备会自动出现在"Video Device"下拉菜单中

---

## 💡 快速使用

### 界面说明

```
┌─────────────────────────────────────────────────┐
│ Video Device: [选择设备▼]  Video Format: [选择格式▼]  [Take Photo] │
├─────────────────────────────────────────────────┤
│                                                 │
│                                                 │
│              实时预览区域                        │
│                                                 │
│                                                 │
└─────────────────────────────────────────────────┘
```

### 基本操作

1. **选择设备**
   - 在"Video Device"下拉菜单中选择您的内窥镜

2. **切换格式**（可选）
   - 在"Video Format"中选择不同的分辨率和格式
   - 格式示例：`1280 x 720  MJPG  30.00 fps`

3. **拍照保存**
   - 点击"Take Photo"按钮
   - 选择保存位置和文件名
   - 照片自动保存为 JPEG 格式

### 照片命名格式

自动生成的文件名格式：
```
20260115_143025_EndoscopeDevice_1280x720.jpg
├─────┬──────┘ ├──────┬──────┘ └────┬─────┘
  日期时间      设备名称        实际分辨率
```

---

## 🛠️ 开发者快速指南

### 前置要求

- macOS 12.0 (Monterey) 或更高版本
- Xcode 14.0 或更高版本
- Xcode Command Line Tools

### 构建命令

```bash
# 查看所有可用命令
make help

# 一键构建（推荐）
make

# 仅构建应用
make build          # Debug 版本
make release        # Release 版本

# 创建 DMG 安装包
make dmg

# 安装到系统
make install

# 测试运行
make test

# 清理构建产物
make clean

# 在 Xcode 中打开
make open
```

### 构建脚本

| 脚本 | 用途 | 示例 |
|------|------|------|
| `./build.sh` | 构建应用 | `./build.sh Release` |
| `./create-dmg.sh` | 创建 DMG | `./create-dmg.sh 1.0` |
| `./quick-build.sh` | 一键构建打包 | `./quick-build.sh` |

### 项目结构

```
EndoscopeViewer/
├── EndoscopeViewer/           # 源代码
│   ├── AppDelegate.swift      # 应用生命周期
│   ├── ViewController.swift   # 主界面控制器
│   ├── CapturePipeline.swift  # 视频捕获管道
│   ├── PreviewView.swift      # 预览视图
│   ├── Models.swift           # 数据模型
│   ├── Main.storyboard        # 界面布局
│   ├── Info.plist             # 应用配置
│   └── Assets.xcassets/       # 资源文件
├── build.sh                   # 构建脚本
├── create-dmg.sh              # DMG 创建脚本
├── quick-build.sh             # 快速构建脚本
├── Makefile                   # Make 构建系统
├── README.md                  # 项目文档（英文）
├── INSTALLATION.md            # 安装指南（中文）
├── ICON_GUIDE.md              # 图标设计指南
└── QUICK_START_CN.md          # 本文档
```

---

## 📖 详细文档

- **[README.md](README.md)** - 项目概述和技术文档（英文）
- **[INSTALLATION.md](INSTALLATION.md)** - 完整的安装、构建和分发指南（中文）
- **[ICON_GUIDE.md](ICON_GUIDE.md)** - 应用图标设计和集成指南
- **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** - 技术实现详解

---

## ✨ 核心特性

### 🎥 低延迟预览
- 使用 AVSampleBufferDisplayLayer 实现
- 硬件加速渲染
- 流畅的实时显示

### 📸 高质量静态捕获
- 专用 AVCapturePhotoOutput（非帧抓取）
- JPEG 格式保存
- 保留完整的元数据信息

### 🎛️ AMCap 风格格式选择
- 技术化的格式标签
- 支持 MJPEG 和 YUV422 格式
- 精确的分辨率和帧率显示

### 🪟 智能窗口大小
- 1:1 像素比例显示
- 超出屏幕自动缩放
- 保持视频纵横比

### 🔒 隐私和安全
- 仅请求必要的摄像头权限
- 无网络连接要求
- 本地保存，完全可控

---

## 🔧 常见问题

### Q: 应用无法打开，提示"无法验证开发者"

**A:** 这是正常的 macOS 安全机制，使用以下方法之一：

**方法 1（推荐）:**
1. 右键点击应用
2. 选择"打开"
3. 在弹窗中点击"打开"

**方法 2:**
```bash
xattr -d com.apple.quarantine /Applications/EndoscopeViewer.app
```

### Q: 设备列表中没有我的摄像头

**A:** 检查：
- USB 连接是否正常
- 设备是否被其他应用占用（如 Photo Booth）
- 在"系统设置 → 隐私与安全性 → 摄像头"中检查权限
- 尝试重新插拔 USB 连接

### Q: 预览显示黑屏

**A:**
- 关闭其他正在使用摄像头的应用
- 尝试切换到不同的视频格式
- 检查设备是否支持当前选择的格式

### Q: 拍照功能不工作

**A:**
- 某些格式可能不支持静态捕获
- 尝试切换到 MJPEG 格式
- 确保有足够的磁盘空间

### Q: 如何修改应用版本号？

**A:** 编辑 `Info.plist`：
```xml
<key>CFBundleShortVersionString</key>
<string>1.0</string>
```

然后重新构建：
```bash
./build.sh Release
```

---

## 🎨 自定义应用图标

应用当前使用默认图标。要添加自定义图标：

1. **准备图标**
   - 创建 1024x1024 的图标图片
   - 保存为 `icon_1024.png`

2. **使用指南**
   - 查看 [ICON_GUIDE.md](ICON_GUIDE.md) 获取详细说明
   - 包含自动化脚本和设计建议

3. **快速生成**
   ```bash
   # 从 1024x1024 生成所有尺寸
   ./generate_icons_from_1024.sh
   ```

---

## 📊 系统要求

### 最低要求
- macOS 12.0 (Monterey)
- 任何 UVC 兼容的摄像头设备

### 推荐配置
- macOS 13.0 (Ventura) 或更高
- USB 3.0 接口
- 1920x1080 或更高分辨率显示器

### 已测试的设备
- USB 网络摄像头
- UVC 牙科内窥镜
- 医疗级内窥镜设备

---

## 🚀 快速命令速查表

```bash
# 构建和打包
./quick-build.sh              # 一键构建所有

# 单独操作
./build.sh Release            # 仅构建
./create-dmg.sh 1.0          # 仅创建 DMG

# 使用 Make
make                         # 构建 + DMG
make install                 # 安装到系统
make test                    # 测试运行
make clean                   # 清理构建

# 直接运行（测试）
open build/EndoscopeViewer.app

# 移除隔离属性
xattr -d com.apple.quarantine build/EndoscopeViewer.app
```

---

## 📝 许可证

本项目为 UVC 牙科内窥镜查看的演示实现。

---

## 🤝 支持与反馈

如有问题或建议：
1. 查看 [INSTALLATION.md](INSTALLATION.md) 详细文档
2. 查看 [README.md](README.md) 技术说明
3. 在项目仓库提交 Issue

---

## 🎉 开始使用

```bash
# 克隆项目
git clone <repository-url>

# 进入目录
cd EndoscopeViewer

# 一键构建
./quick-build.sh

# 安装使用
make install
```

**祝您使用愉快！** 🚀

---

**版本**: 1.0
**更新日期**: 2026-01-15
**兼容性**: macOS 12.0+
