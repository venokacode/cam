//
//  PreviewView.swift
//  EndoscopeViewer
//
//  Custom NSView hosting AVSampleBufferDisplayLayer for low-latency preview
//

import AppKit
import AVFoundation

class PreviewView: NSView {

    private var displayLayer: AVSampleBufferDisplayLayer!

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupDisplayLayer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDisplayLayer()
    }

    private func setupDisplayLayer() {
        wantsLayer = true

        displayLayer = AVSampleBufferDisplayLayer()
        displayLayer.videoGravity = .resizeAspect
        displayLayer.backgroundColor = NSColor.black.cgColor

        if let layer = self.layer {
            layer.addSublayer(displayLayer)
        }
    }

    override func layout() {
        super.layout()
        // Match display layer to view bounds
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        displayLayer.frame = bounds
        CATransaction.commit()
    }

    /// Enqueue a sample buffer for display
    /// Call from main thread for MVP stability
    func enqueue(sampleBuffer: CMSampleBuffer) {
        guard displayLayer.isReadyForMoreMediaData else {
            return
        }
        displayLayer.enqueue(sampleBuffer)
    }

    /// Flush the display layer (useful when stopping/reconfiguring)
    func flush() {
        displayLayer.flush()
    }
}
