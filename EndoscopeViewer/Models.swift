//
//  Models.swift
//  EndoscopeViewer
//
//  macOS UVC Dental Endoscope Viewer
//

import AVFoundation
import CoreMedia

// MARK: - Device Item

struct DeviceItem {
    let device: AVCaptureDevice
    let displayName: String

    init(device: AVCaptureDevice) {
        self.device = device
        self.displayName = device.localizedName
    }
}

// MARK: - Mode Item

struct ModeItem {
    let format: AVCaptureDevice.Format
    let displayLabel: String
    let width: Int
    let height: Int
    let fps: Double
    let fourCC: String

    init(format: AVCaptureDevice.Format) {
        self.format = format

        // Extract dimensions
        let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
        self.width = Int(dimensions.width)
        self.height = Int(dimensions.height)

        // Extract pixel format and normalize to AMCap-style
        let pixelFormat = CMFormatDescriptionGetMediaSubType(format.formatDescription)
        self.fourCC = ModeItem.normalizedFourCC(pixelFormat)

        // Extract frame rate
        let frameRateRanges = format.videoSupportedFrameRateRanges
        var maxFrameRate: Double = 30.0
        if let firstRange = frameRateRanges.first {
            maxFrameRate = firstRange.maxFrameRate
            // Treat 29.97 as 30
            if maxFrameRate > 29.9 && maxFrameRate < 30.1 {
                maxFrameRate = 30.0
            }
        }
        self.fps = maxFrameRate

        // Build AMCap-style label: "1280 x 720  MJPG  30.00 fps"
        self.displayLabel = String(format: "%d x %d  %@  %.2f fps",
                                   width, height, fourCC, fps)
    }

    // Normalize FOURCC to AMCap-style strings
    static func normalizedFourCC(_ pixelFormat: FourCharCode) -> String {
        switch pixelFormat {
        case kCMVideoCodecType_JPEG_OpenDML:
            return "MJPG"
        case kCVPixelFormatType_422YpCbCr8:      // '2vuy'
            return "YUY2"
        case kCVPixelFormatType_422YpCbCr8_yuvs: // 'yuvs'
            return "YUY2"
        default:
            // Convert FourCharCode to string for other formats
            let chars = [
                UInt8((pixelFormat >> 24) & 0xFF),
                UInt8((pixelFormat >> 16) & 0xFF),
                UInt8((pixelFormat >> 8) & 0xFF),
                UInt8(pixelFormat & 0xFF)
            ]
            return String(bytes: chars, encoding: .ascii) ?? "????"
        }
    }
}

// MARK: - Mode Listing

extension AVCaptureDevice {
    /// Returns filtered list of formats suitable for UVC endoscopes
    /// - Supports MJPEG and YUV422 formats
    /// - Frame rate <= 30 fps
    /// - Common resolutions: 1280x720, 640x480, 1920x1080
    func endoscopeModes() -> [ModeItem] {
        return formats.compactMap { format -> ModeItem? in
            let pixelFormat = CMFormatDescriptionGetMediaSubType(format.formatDescription)

            // Filter supported pixel formats
            let isMJPEG = (pixelFormat == kCMVideoCodecType_JPEG_OpenDML)
            let isYUV422 = (pixelFormat == kCVPixelFormatType_422YpCbCr8 ||
                           pixelFormat == kCVPixelFormatType_422YpCbCr8_yuvs)

            guard isMJPEG || isYUV422 else {
                return nil
            }

            // Filter frame rate <= 30 fps
            guard let frameRateRange = format.videoSupportedFrameRateRanges.first else {
                return nil
            }

            if frameRateRange.maxFrameRate > 30.1 {
                return nil
            }

            return ModeItem(format: format)
        }.sorted { lhs, rhs in
            // Sort by: resolution (descending), then fps (descending), then fourCC
            if lhs.width != rhs.width {
                return lhs.width > rhs.width
            }
            if lhs.height != rhs.height {
                return lhs.height > rhs.height
            }
            if lhs.fps != rhs.fps {
                return lhs.fps > rhs.fps
            }
            return lhs.fourCC < rhs.fourCC
        }
    }

    /// Find the ModeItem that matches the device's current activeFormat
    func findActiveModeItem(in modes: [ModeItem]) -> ModeItem? {
        return modes.first { $0.format == self.activeFormat }
    }
}
