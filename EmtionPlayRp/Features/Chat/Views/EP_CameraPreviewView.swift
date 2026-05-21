//
//  EP_CameraPreviewView.swift
//  EmtionPlayRp
//

import AVFoundation
import UIKit

/// 本地相机预览
final class EP_CameraPreviewView: UIView {

    private let session = AVCaptureSession()
    private var currentInput: AVCaptureDeviceInput?
    private var isUsingFrontCamera = true

    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    private var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    func start() {
        configureInput()
        videoPreviewLayer.session = session
        videoPreviewLayer.videoGravity = .resizeAspectFill

        guard !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }

    func stop() {
        guard session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
        }
    }

    func switchCamera() {
        isUsingFrontCamera.toggle()
        configureInput()
    }

    private func configureInput() {
        session.beginConfiguration()
        if session.canSetSessionPreset(.high) {
            session.sessionPreset = .high
        }

        if let currentInput {
            session.removeInput(currentInput)
            self.currentInput = nil
        }

        guard let device = captureDevice(position: isUsingFrontCamera ? .front : .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            session.commitConfiguration()
            return
        }
        session.addInput(input)
        currentInput = input
        session.commitConfiguration()
    }

    private func captureDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: position
        ).devices.first
    }
}
