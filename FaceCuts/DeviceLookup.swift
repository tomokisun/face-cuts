import AVFoundation

final class DeviceLookup {
  private let frontCameraDiscoverySession: AVCaptureDevice.DiscoverySession
  private let backCameraDiscoverySession: AVCaptureDevice.DiscoverySession
  
  init() {
    backCameraDiscoverySession = AVCaptureDevice.DiscoverySession(
      deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera],
      mediaType: .video,
      position: .back
    )
    frontCameraDiscoverySession = AVCaptureDevice.DiscoverySession(
      deviceTypes: [.builtInTrueDepthCamera, .builtInWideAngleCamera],
      mediaType: .video,
      position: .front
    )
  }
  
  var frontCamera: AVCaptureDevice {
    get throws {
      guard let camera = frontCameraDiscoverySession.devices.first else {
        throw CameraError.videoDeviceUnavailable
      }
      return camera
    }
  }
  
  var backCamera: AVCaptureDevice {
    get throws {
      guard let camera = backCameraDiscoverySession.devices.first else {
        throw CameraError.videoDeviceUnavailable
      }
      return camera
    }
  }
}
