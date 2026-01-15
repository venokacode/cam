# App Icon Design Guide

## 图标说明

EndoscopeViewer 应用需要一套完整的 macOS 应用图标。图标资源目录已创建在：
```
EndoscopeViewer/Assets.xcassets/AppIcon.appiconset/
```

## 所需图标尺寸

macOS 应用需要以下尺寸的图标（@1x 和 @2x）：

| 尺寸 | 用途 | 文件名 |
|------|------|--------|
| 16x16 | Finder, Dock (缩小) | icon_16x16.png, icon_16x16@2x.png |
| 32x32 | Finder, Dock | icon_32x32.png, icon_32x32@2x.png |
| 128x128 | Finder (大图标) | icon_128x128.png, icon_128x128@2x.png |
| 256x256 | Finder (更大图标) | icon_256x256.png, icon_256x256@2x.png |
| 512x512 | Retina 显示屏 | icon_512x512.png, icon_512x512@2x.png |

## 设计建议

### 主题概念
由于这是医疗内窥镜查看器应用，建议的设计元素：

1. **医疗相关图标**：
   - 内窥镜设备轮廓
   - 摄像头图标
   - 牙齿图标（针对牙科内窥镜）
   - 医疗十字标志

2. **技术相关图标**：
   - 摄像机镜头
   - 播放/预览图标
   - 视频帧图标

3. **颜色方案**：
   - 主色：医疗蓝色 (#0066CC 或 #1E88E5)
   - 辅色：白色、浅灰色
   - 强调色：绿色（表示健康/安全）

### 设计规范

- **风格**：现代扁平化设计
- **形状**：圆角矩形（macOS 标准）
- **阴影**：适度的投影以增加立体感
- **细节**：在小尺寸（16x16）下仍然清晰可辨

## 创建图标的方法

### 方法 1: 使用专业设计工具

#### Sketch
1. 创建 1024x1024 的画布
2. 设计图标
3. 导出所需的所有尺寸

#### Figma
1. 使用 macOS App Icon 模板
2. 设计图标
3. 使用插件导出所有尺寸

#### Adobe Illustrator
1. 创建矢量图标
2. 导出为多个 PNG 尺寸

### 方法 2: 使用在线图标生成器

推荐的在线工具：
- **IconKitchen** (iconkitchen.com)
- **App Icon Generator** (appicon.co)
- **MakeAppIcon** (makeappicon.com)

### 方法 3: 使用命令行工具

如果您有一个 1024x1024 的主图标：

```bash
# 使用 sips (macOS 内置工具) 生成不同尺寸
sips -z 16 16 icon_1024.png --out icon_16x16.png
sips -z 32 32 icon_1024.png --out icon_16x16@2x.png
sips -z 32 32 icon_1024.png --out icon_32x32.png
sips -z 64 64 icon_1024.png --out icon_32x32@2x.png
sips -z 128 128 icon_1024.png --out icon_128x128.png
sips -z 256 256 icon_1024.png --out icon_128x128@2x.png
sips -z 256 256 icon_1024.png --out icon_256x256.png
sips -z 512 512 icon_1024.png --out icon_256x256@2x.png
sips -z 512 512 icon_1024.png --out icon_512x512.png
sips -z 1024 1024 icon_1024.png --out icon_512x512@2x.png
```

### 方法 4: 使用 iconutil (推荐)

创建 `.iconset` 文件夹并使用 iconutil：

```bash
# 创建 iconset 文件夹
mkdir EndoscopeViewer.iconset

# 生成所有尺寸的图标（从 1024x1024 源文件）
sips -z 16 16     icon_1024.png --out EndoscopeViewer.iconset/icon_16x16.png
sips -z 32 32     icon_1024.png --out EndoscopeViewer.iconset/icon_16x16@2x.png
sips -z 32 32     icon_1024.png --out EndoscopeViewer.iconset/icon_32x32.png
sips -z 64 64     icon_1024.png --out EndoscopeViewer.iconset/icon_32x32@2x.png
sips -z 128 128   icon_1024.png --out EndoscopeViewer.iconset/icon_128x128.png
sips -z 256 256   icon_1024.png --out EndoscopeViewer.iconset/icon_128x128@2x.png
sips -z 256 256   icon_1024.png --out EndoscopeViewer.iconset/icon_256x256.png
sips -z 512 512   icon_1024.png --out EndoscopeViewer.iconset/icon_256x256@2x.png
sips -z 512 512   icon_1024.png --out EndoscopeViewer.iconset/icon_512x512.png
sips -z 1024 1024 icon_1024.png --out EndoscopeViewer.iconset/icon_512x512@2x.png

# 生成 .icns 文件
iconutil -c icns EndoscopeViewer.iconset
```

## 添加图标到项目

### 步骤 1: 准备图标文件

将所有尺寸的图标 PNG 文件放入：
```
EndoscopeViewer/Assets.xcassets/AppIcon.appiconset/
```

### 步骤 2: 更新 Contents.json

编辑 `Contents.json` 文件，为每个尺寸添加文件名：

```json
{
  "images" : [
    {
      "filename" : "icon_16x16.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "16x16"
    },
    {
      "filename" : "icon_16x16@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "16x16"
    },
    // ... 其他尺寸
  ]
}
```

### 步骤 3: 在 Xcode 中验证

1. 打开 Xcode 项目
2. 在项目导航器中选择 `Assets.xcassets`
3. 选择 `AppIcon`
4. 拖拽图标文件到对应的位置

### 步骤 4: 重新构建

```bash
./build.sh Release
```

## 快速开始模板

### 使用 SF Symbols（macOS 自带图标）

如果您想快速创建一个简单的图标：

```bash
# 创建一个脚本来生成基于 SF Symbol 的图标
cat > generate_icon.sh << 'EOF'
#!/bin/bash
# 使用 sf-symbols 生成基础图标
# 需要安装 SF Symbols 应用

# 这个脚本使用 video.fill symbol 作为示例
# 您可以在 SF Symbols 应用中选择其他图标

# 生成 1024x1024 的基础图标
echo "请使用以下步骤手动创建图标："
echo "1. 打开 SF Symbols 应用"
echo "2. 搜索 'video' 或 'camera' 图标"
echo "3. 拖拽到 Preview 或图片编辑器"
echo "4. 导出为 1024x1024 PNG"
echo "5. 运行 generate_icons_from_1024.sh"
EOF

chmod +x generate_icon.sh
```

### 从 1024x1024 生成所有尺寸

创建 `generate_icons_from_1024.sh`：

```bash
#!/bin/bash
# 从单个 1024x1024 源文件生成所有需要的图标尺寸

SOURCE="icon_1024.png"
ICONSET="EndoscopeViewer.iconset"

if [ ! -f "$SOURCE" ]; then
    echo "错误: 找不到 $SOURCE"
    echo "请先创建一个 1024x1024 的 icon_1024.png 文件"
    exit 1
fi

# 创建 iconset 目录
mkdir -p "$ICONSET"

# 生成所有尺寸
echo "生成图标..."
sips -z 16 16     "$SOURCE" --out "$ICONSET/icon_16x16.png"
sips -z 32 32     "$SOURCE" --out "$ICONSET/icon_16x16@2x.png"
sips -z 32 32     "$SOURCE" --out "$ICONSET/icon_32x32.png"
sips -z 64 64     "$SOURCE" --out "$ICONSET/icon_32x32@2x.png"
sips -z 128 128   "$SOURCE" --out "$ICONSET/icon_128x128.png"
sips -z 256 256   "$SOURCE" --out "$ICONSET/icon_128x128@2x.png"
sips -z 256 256   "$SOURCE" --out "$ICONSET/icon_256x256.png"
sips -z 512 512   "$SOURCE" --out "$ICONSET/icon_256x256@2x.png"
sips -z 512 512   "$SOURCE" --out "$ICONSET/icon_512x512.png"
sips -z 1024 1024 "$SOURCE" --out "$ICONSET/icon_512x512@2x.png"

# 生成 .icns 文件
echo "生成 .icns 文件..."
iconutil -c icns "$ICONSET" -o "EndoscopeViewer.icns"

# 复制到项目
echo "复制到项目..."
cp "$ICONSET"/* "EndoscopeViewer/Assets.xcassets/AppIcon.appiconset/"

echo "完成! 图标已生成并复制到项目中"
echo "现在可以运行 ./build.sh 重新构建应用"
```

## 简易图标方案（无需设计）

如果您暂时不想设计专业图标，可以：

1. **使用系统图标**：
   - 从 `/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/` 复制一个类似的图标

2. **使用占位符**：
   - 创建一个简单的蓝色圆角矩形
   - 添加白色的摄像头或医疗图标

3. **使用在线生成器**：
   - 访问 iconkitchen.com
   - 选择医疗或相机模板
   - 下载生成的图标集

## 图标检查清单

在提交应用前，请确保：

- [ ] 所有尺寸的图标都已创建（10 个文件）
- [ ] 图标在所有尺寸下都清晰可辨
- [ ] 图标背景适当（透明或纯色）
- [ ] 图标符合 macOS 设计规范
- [ ] 在 Finder 中预览图标效果
- [ ] 在 Dock 中测试图标显示
- [ ] 重新构建应用并验证

## 参考资源

- [Apple Human Interface Guidelines - App Icons](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [SF Symbols](https://developer.apple.com/sf-symbols/)
- [IconKitchen](https://iconkitchen.com/)
- [AppIcon.co](https://www.appicon.co/)

---

**注意**：应用图标不是必需的，应用在没有自定义图标的情况下会使用默认的通用应用图标。但添加自定义图标可以提升应用的专业性和可识别性。
