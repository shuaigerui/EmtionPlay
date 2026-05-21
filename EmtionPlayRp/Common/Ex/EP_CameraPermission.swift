//
//  EP_CameraPermission.swift
//  EmtionPlayRp
//

import AVFoundation
import UIKit

/// 相机权限检查与引导
enum EP_CameraPermission {

    static func checkCameraAccess(
        from viewController: UIViewController,
        onGranted: @escaping () -> Void
    ) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            onGranted()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        onGranted()
                    } else {
                        showDeniedAlert(from: viewController)
                    }
                }
            }
        case .denied, .restricted:
            showDeniedAlert(from: viewController)
        @unknown default:
            showDeniedAlert(from: viewController)
        }
    }

    static func showDeniedAlert(from viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Camera Access Required",
            message: "Please enable camera access in Settings to start a video call.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url)
        })
        viewController.present(alert, animated: true)
    }
}
