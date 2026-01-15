//
//  CapturePipeline.swift
//  EndoscopeViewer
//
//  Manages AVCaptureSession, video preview, and still photo capture
//

import AVFoundation
import AppKit
import CoreMedia

protocol CapturePipelineDelegate: AnyObject {
    func capturePipeline(_ pipeline: CapturePipeline, didOutput sampleBuffer: CMSampleBuffer)
    func capturePipeline(_ pipeline: CapturePipeline, didCapture photoData: Data, metadata: [String: Any], deviceName: String)
    func capturePipeline(_ pipeline: CapturePipeline, didFailWithError error: Error)
}

class CapturePipeline: NSObject {

    weak var delegate: CapturePipelineDelegate?

    private let session = AVCaptureSession()
    private var deviceInput: AVCaptureDeviceInput?
    private let videoOutput = AVCaptureVideoDataOutput()
    private let photoOutput = AVCapturePhotoOutput()

    private let videoQueue = DispatchQueue(label: "com.endoscope.video",
                                          qos: .userInteractive)

    private var currentDevice: AVCaptureDevice?

    override init() {
        super.init()
        configureSession()
    }

    // MARK: - Session Configuration

    private func configureSession() {
        // Use .inputPriority preset if available (macOS 12+), otherwise default
        if #available(macOS 12.0, *) {
            session.sessionPreset = .inputPriority
        }

        // Configure video output for preview
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)

        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }

        // Configure photo output for still capture
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
    }

    // MARK: - Device Management

    /// Start capture with the specified device using its default format
    /// Does NOT override device.activeFormat
    func startCapture(with device: AVCaptureDevice) throws {
        stopCapture()

        session.beginConfiguration()

        // Add device input
        let input = try AVCaptureDeviceInput(device: device)
        if session.canAddInput(input) {
            session.addInput(input)
            deviceInput = input
            currentDevice = device
        } else {
            session.commitConfiguration()
            throw NSError(domain: "CapturePipeline",
                         code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Cannot add device input"])
        }

        session.commitConfiguration()

        // Start session on background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }

    /// Stop current capture session
    func stopCapture() {
        if session.isRunning {
            session.stopRunning()
        }

        session.beginConfiguration()

        if let input = deviceInput {
            session.removeInput(input)
            deviceInput = nil
        }

        session.commitConfiguration()

        currentDevice = nil
    }

    // MARK: - Format Management

    /// Apply a new format to the current device
    /// Only call this when user explicitly changes format
    func applyFormat(_ format: AVCaptureDevice.Format) throws {
        guard let device = currentDevice else {
            throw NSError(domain: "CapturePipeline",
                         code: -2,
                         userInfo: [NSLocalizedDescriptionKey: "No active device"])
        }

        // Stop session for stability during format change
        let wasRunning = session.isRunning
        if wasRunning {
            session.stopRunning()
        }

        try device.lockForConfiguration()

        // Set the new format
        device.activeFormat = format

        // If format supports ~30fps, fix frame duration
        if let frameRateRange = format.videoSupportedFrameRateRanges.first {
            let maxFPS = frameRateRange.maxFrameRate
            if maxFPS > 29.0 && maxFPS < 31.0 {
                let duration = CMTime(value: 1, timescale: 30)
                device.activeVideoMinFrameDuration = duration
                device.activeVideoMaxFrameDuration = duration
            }
        }

        device.unlockForConfiguration()

        // Restart session
        if wasRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.startRunning()
            }
        }
    }

    // MARK: - Still Capture

    /// Capture a still photo using AVCapturePhotoOutput
    func capturePhoto() {
        guard photoOutput.connection(with: .video) != nil else {
            return
        }

        let settings = AVCapturePhotoSettings()

        // Request JPEG format
        settings.flashMode = .off

        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    // MARK: - Current Device Info

    var deviceName: String {
        return currentDevice?.localizedName ?? "Unknown"
    }

    var isRunning: Bool {
        return session.isRunning
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CapturePipeline: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput,
                      didOutput sampleBuffer: CMSampleBuffer,
                      from connection: AVCaptureConnection) {
        // Forward to delegate on main thread for MVP stability
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.capturePipeline(self, didOutput: sampleBuffer)
        }
    }

    func captureOutput(_ output: AVCaptureOutput,
                      didDrop sampleBuffer: CMSampleBuffer,
                      from connection: AVCaptureConnection) {
        // Ignore dropped frames (alwaysDiscardsLateVideoFrames is enabled)
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CapturePipeline: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput,
                    didFinishProcessingPhoto photo: AVCapturePhoto,
                    error: Error?) {
        if let error = error {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.capturePipeline(self, didFailWithError: error)
            }
            return
        }

        guard let photoData = photo.fileDataRepresentation() else {
            let err = NSError(domain: "CapturePipeline",
                             code: -3,
                             userInfo: [NSLocalizedDescriptionKey: "Failed to get photo data"])
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.capturePipeline(self, didFailWithError: err)
            }
            return
        }

        // Extract metadata (contains actual output dimensions if available)
        var metadata: [String: Any] = [:]

        // Try to get dimensions from CGImagePropertyOrientation or resolved settings
        let dimensions = photo.resolvedSettings.photoDimensions
        metadata["width"] = Int(dimensions.width)
        metadata["height"] = Int(dimensions.height)

        // Get device name
        let deviceName = self.deviceName

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.capturePipeline(self,
                                          didCapture: photoData,
                                          metadata: metadata,
                                          deviceName: deviceName)
        }
    }
}
