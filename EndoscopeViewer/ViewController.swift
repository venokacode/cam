//
//  ViewController.swift
//  EndoscopeViewer
//
//  Main view controller for endoscope viewer UI
//

import Cocoa
import AVFoundation
import CoreMedia

class ViewController: NSViewController {

    // MARK: - UI Outlets

    @IBOutlet weak var devicePopup: NSPopUpButton!
    @IBOutlet weak var modePopup: NSPopUpButton!
    @IBOutlet weak var takePhotoButton: NSButton!
    @IBOutlet weak var previewView: PreviewView!

    // MARK: - Properties

    private let capturePipeline = CapturePipeline()
    private var devices: [DeviceItem] = []
    private var modes: [ModeItem] = []

    private var hasReceivedFirstFrame = false
    private var currentVideoDimensions: CGSize?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        capturePipeline.delegate = self

        setupUI()
        discoverDevices()

        // Start with first device if available
        if !devices.isEmpty {
            devicePopup.selectItem(at: 0)
            deviceDidChange()
        }
    }

    // MARK: - UI Setup

    private func setupUI() {
        takePhotoButton.isEnabled = false
    }

    // MARK: - Device Discovery

    private func discoverDevices() {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.externalUnknown],
            mediaType: .video,
            position: .unspecified
        )

        devices = discoverySession.devices.map { DeviceItem(device: $0) }

        // Populate device popup
        devicePopup.removeAllItems()
        for deviceItem in devices {
            devicePopup.addItem(withTitle: deviceItem.displayName)
        }

        devicePopup.isEnabled = !devices.isEmpty
    }

    // MARK: - Device Selection

    @IBAction func devicePopupChanged(_ sender: NSPopUpButton) {
        deviceDidChange()
    }

    private func deviceDidChange() {
        let selectedIndex = devicePopup.indexOfSelectedItem
        guard selectedIndex >= 0 && selectedIndex < devices.count else {
            return
        }

        let deviceItem = devices[selectedIndex]
        let device = deviceItem.device

        // Stop current capture
        capturePipeline.stopCapture()
        previewView.flush()

        // Update modes for new device
        modes = device.endoscopeModes()

        modePopup.removeAllItems()
        for modeItem in modes {
            modePopup.addItem(withTitle: modeItem.displayLabel)
        }

        modePopup.isEnabled = !modes.isEmpty

        // Start capture with device defaults (do NOT override activeFormat)
        do {
            try capturePipeline.startCapture(with: device)

            // Select the mode item that matches the device's activeFormat
            if let activeModeItem = device.findActiveModeItem(in: modes),
               let index = modes.firstIndex(where: { $0.format == activeModeItem.format }) {
                modePopup.selectItem(at: index)
            } else if !modes.isEmpty {
                modePopup.selectItem(at: 0)
            }

            takePhotoButton.isEnabled = true
            hasReceivedFirstFrame = false

        } catch {
            showError("Failed to start capture: \(error.localizedDescription)")
            takePhotoButton.isEnabled = false
        }
    }

    // MARK: - Mode Selection

    @IBAction func modePopupChanged(_ sender: NSPopUpButton) {
        modeDidChange()
    }

    private func modeDidChange() {
        let selectedIndex = modePopup.indexOfSelectedItem
        guard selectedIndex >= 0 && selectedIndex < modes.count else {
            return
        }

        let modeItem = modes[selectedIndex]

        // Apply format (user explicitly changed it)
        do {
            try capturePipeline.applyFormat(modeItem.format)
            hasReceivedFirstFrame = false
        } catch {
            showError("Failed to apply format: \(error.localizedDescription)")
        }
    }

    // MARK: - Photo Capture

    @IBAction func takePhotoClicked(_ sender: NSButton) {
        capturePipeline.capturePhoto()
    }

    // MARK: - Window Sizing

    private func resizeWindowToFit(videoDimensions: CGSize) {
        guard let window = view.window else { return }

        // Avoid redundant resizing
        if let current = currentVideoDimensions,
           current.width == videoDimensions.width && current.height == videoDimensions.height {
            return
        }
        currentVideoDimensions = videoDimensions

        // Calculate required window size
        // Preview size should be 1:1 with video dimensions
        var targetPreviewSize = videoDimensions

        // Get screen visible frame
        guard let screen = window.screen else { return }
        let visibleFrame = screen.visibleFrame

        // Calculate UI chrome height (toolbar + controls + margins)
        // Estimate: title bar ~28, toolbar ~40, margins ~20
        let chromeHeight: CGFloat = 88

        // Maximum available size for preview
        let maxPreviewWidth = visibleFrame.width - 40  // 20px margin on each side
        let maxPreviewHeight = visibleFrame.height - chromeHeight - 40

        // Scale down if needed, maintaining aspect ratio
        if targetPreviewSize.width > maxPreviewWidth || targetPreviewSize.height > maxPreviewHeight {
            let scaleX = maxPreviewWidth / targetPreviewSize.width
            let scaleY = maxPreviewHeight / targetPreviewSize.height
            let scale = min(scaleX, scaleY)

            targetPreviewSize.width = floor(targetPreviewSize.width * scale)
            targetPreviewSize.height = floor(targetPreviewSize.height * scale)
        }

        // Calculate new window frame
        let newWindowWidth = targetPreviewSize.width + 40  // 20px margin each side
        let newWindowHeight = targetPreviewSize.height + chromeHeight

        let currentFrame = window.frame
        let newFrame = NSRect(
            x: currentFrame.origin.x,
            y: currentFrame.origin.y + (currentFrame.height - newWindowHeight),
            width: newWindowWidth,
            height: newWindowHeight
        )

        // Animate window resize
        window.setFrame(newFrame, display: true, animate: true)
    }

    // MARK: - Error Handling

    private func showError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "Error"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    private func showInfo(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "Success"
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    // MARK: - Save Photo

    private func savePhoto(data: Data, metadata: [String: Any], deviceName: String) {
        // Generate filename: YYYYMMDD_HHMMSS_<DeviceName>_<WxH>.jpg
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = dateFormatter.string(from: Date())

        let width = metadata["width"] as? Int ?? 0
        let height = metadata["height"] as? Int ?? 0

        let cleanDeviceName = deviceName.replacingOccurrences(of: " ", with: "_")
                                       .replacingOccurrences(of: "/", with: "_")

        let filename = "\(timestamp)_\(cleanDeviceName)_\(width)x\(height).jpg"

        // Present save panel
        let savePanel = NSSavePanel()
        savePanel.nameFieldStringValue = filename
        savePanel.allowedContentTypes = [.jpeg]
        savePanel.canCreateDirectories = true

        savePanel.begin { [weak self] response in
            guard response == .OK, let url = savePanel.url else {
                return
            }

            do {
                try data.write(to: url)
                self?.showInfo("Photo saved to:\n\(url.path)")
            } catch {
                self?.showError("Failed to save photo: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - CapturePipelineDelegate

extension ViewController: CapturePipelineDelegate {

    func capturePipeline(_ pipeline: CapturePipeline, didOutput sampleBuffer: CMSampleBuffer) {
        // Enqueue buffer to preview
        previewView.enqueue(sampleBuffer: sampleBuffer)

        // Resize window on first frame or dimension change
        if !hasReceivedFirstFrame {
            hasReceivedFirstFrame = true

            // Extract video dimensions
            if let formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer) {
                let dimensions = CMVideoFormatDescriptionGetDimensions(formatDesc)
                let videoSize = CGSize(width: CGFloat(dimensions.width),
                                      height: CGFloat(dimensions.height))

                resizeWindowToFit(videoDimensions: videoSize)
            }
        }
    }

    func capturePipeline(_ pipeline: CapturePipeline,
                        didCapture photoData: Data,
                        metadata: [String: Any],
                        deviceName: String) {
        savePhoto(data: photoData, metadata: metadata, deviceName: deviceName)
    }

    func capturePipeline(_ pipeline: CapturePipeline, didFailWithError error: Error) {
        showError("Capture error: \(error.localizedDescription)")
    }
}
