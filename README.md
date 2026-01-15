# EndoscopeViewer - macOS UVC Dental Endoscope Viewer

A native macOS desktop application for viewing and capturing images from UVC dental endoscopes, built with Swift and AppKit.

## Features

- **Low-latency live preview** using AVSampleBufferDisplayLayer
- **Still photo capture** via AVCapturePhotoOutput (dedicated still pin)
- **AMCap-style format selection** with technical labels (e.g., "1280 x 720  MJPG  30.00 fps")
- **Pixel-perfect window sizing** (1:1 with video dimensions, scaled down if needed)
- **Supports common UVC formats**: MJPEG and YUV422 (YUY2)
- **No recording** - focused on live viewing and still capture only
- **macOS 12.0+ compatible**

## Quick Start

### For End Users (Installation)

**Download and install the pre-built application:**

1. Download `EndoscopeViewer-1.0.dmg` from the releases page
2. Open the DMG file
3. Drag `EndoscopeViewer.app` to the `Applications` folder
4. Launch from Applications and grant camera permission

### For Developers (Build from Source)

**One-command build:**

```bash
cd EndoscopeViewer
./quick-build.sh
```

This will build the app and create distributable packages (DMG and ZIP).

📖 **详细的构建、安装和分发说明请参见 [INSTALLATION.md](INSTALLATION.md)（中文）**

## Requirements

### For Running
- macOS 12.0 (Monterey) or later
- UVC-compatible camera device (USB webcam, endoscope, etc.)

### For Building
- macOS 12.0 (Monterey) or later
- Xcode 14.0 or later
- Xcode Command Line Tools

## Building the Project

### Quick Build (Recommended)

```bash
./quick-build.sh
```

This script will:
- Build Release version
- Create ZIP archive
- Generate DMG installer

Output files will be in the `build/` directory.

### Option 1: Using Build Script

```bash
# Build Release version
./build.sh Release

# Or build Debug version
./build.sh Debug
```

### Option 2: Using Xcode

1. Open `EndoscopeViewer.xcodeproj` in Xcode
2. Select your development team in project settings (for code signing)
3. Build and run (⌘R)

### Option 3: Using Command Line

```bash
xcodebuild -scheme EndoscopeViewer -configuration Release build
```

## Creating Distribution Package

### Create DMG Installer

```bash
# First build the app
./build.sh Release

# Then create DMG (specify version)
./create-dmg.sh 1.0
```

The DMG file will be created at: `build/EndoscopeViewer-1.0.dmg`

## Usage

### First Launch

1. Launch the application
2. Grant camera permission when prompted
3. Your UVC device should appear in the "Video Device" dropdown

### Selecting Device and Format

- **Video Device**: Choose your endoscope from the dropdown
- **Video Format**: Select desired resolution and pixel format
  - The app starts with the device's default format
  - You can switch to any supported format (MJPEG or YUY2)
  - Format changes are applied immediately

### Capturing Photos

1. Click "Take Photo" button
2. Choose save location and filename
3. Default filename format: `YYYYMMDD_HHMMSS_<DeviceName>_<WxH>.jpg`
4. Photos are saved as JPEG with actual still output dimensions

### Window Sizing

- The preview window automatically resizes to match video dimensions (1:1 pixel ratio)
- If the video would exceed screen size, the window scales down proportionally
- Window resizes when format changes or on first video frame

## Technical Details

### Architecture

The application consists of five main components:

1. **Models.swift** - Data models and FOURCC normalization
   - `DeviceItem`: Wrapper for AVCaptureDevice
   - `ModeItem`: Represents a video format with AMCap-style label
   - Format filtering and sorting logic

2. **PreviewView.swift** - Custom NSView for video display
   - Hosts `AVSampleBufferDisplayLayer` for low-latency rendering
   - Handles buffer enqueueing and display layer management

3. **CapturePipeline.swift** - AVFoundation capture session management
   - Manages `AVCaptureSession` with two outputs:
     - `AVCaptureVideoDataOutput` for preview
     - `AVCapturePhotoOutput` for still capture
   - Handles device connection and format changes
   - Delegates video frames and captured photos

4. **ViewController.swift** - Main UI controller
   - Populates device and format popups
   - Handles user interactions
   - Manages window sizing based on video dimensions
   - Implements photo save workflow

5. **AppDelegate.swift** - Application lifecycle

### Supported Pixel Formats

The application filters and displays only formats suitable for UVC endoscopes:

- **MJPEG** (Motion JPEG) - Compressed format, efficient for USB transfer
- **YUY2/YUV422** - Uncompressed format, higher quality but more bandwidth

All formats are limited to ≤30 fps to match typical endoscope capabilities.

### Default Behavior

- On startup, the app uses the device's **default active format**
- The format popup reflects the current format but does **not** apply changes automatically
- Format changes are **only** applied when the user explicitly selects a different format
- This prevents unwanted format overrides and respects device defaults

### Photo Capture Details

- Uses **AVCapturePhotoOutput** for dedicated still capture (not frame grabbing)
- Photos use the device's still image output (may differ from preview resolution)
- Saved as JPEG with proper metadata
- Filename includes actual captured dimensions (not preview dimensions)

## Permissions

The app requires camera access to function. On first launch, macOS will prompt for permission. You can manage permissions in:

**System Settings → Privacy & Security → Camera**

## Known Limitations

- No video recording (by design - focused on still capture only)
- No camera control UI (exposure, white balance, focus adjustment)
- No always-on-top/floating window mode
- Supports MJPEG and YUV422 formats only (most common for UVC devices)

## Troubleshooting

### Camera not appearing in device list

- Check that the camera is connected via USB
- Verify the camera works in Photo Booth or another app
- Check camera permissions in System Settings
- Try disconnecting and reconnecting the camera

### Preview shows black screen

- Ensure another application isn't using the camera
- Check that the selected format is compatible with your device
- Try switching to a different video format

### Photo capture fails

- Verify that the device supports still capture on the selected format
- Some devices may only support still capture on specific formats
- Try switching to MJPEG format if using YUV422

### Build errors in Xcode

- Ensure macOS deployment target is set to 12.0
- Verify all Swift files are included in the target
- Clean build folder (⇧⌘K) and rebuild

## License

This is a demonstration project for UVC dental endoscope viewing.

## Support

For issues or questions, refer to the project documentation or open an issue in the repository.
