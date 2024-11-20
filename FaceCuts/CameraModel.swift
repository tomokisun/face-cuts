import SwiftUI
import Combine
import PhotosUI
import CoreVideo

@Observable
class CameraModel: Camera {
  private(set) var status = CameraStatus.unknown
  
  private(set) var pixelBuffer: CVPixelBuffer?

  var selection: PhotosPickerItem?
  private(set) var backgroundImageData: Data?
  
  var captureSession: AVCaptureSession { captureService.captureSession }
  private let captureService = CaptureService()
  
  func start() async {
    guard await captureService.isAuthorized else {
      status = .unauthorized
      return
    }

    do {
      try await captureService.start()
      observeState()
      status = .running
    } catch {
      print("Failed to start capture service. \(error)")
      status = .failed
    }
  }
  
  func loadBackgroundImage() async throws {
    guard let selection else { return }
    backgroundImageData = try await selection.loadTransferable(type: Data.self)
  }
  
  private func observeState() {
    Task {
      for await buffer in captureService.videoCapture.$currentPixelBuffer.values {
        pixelBuffer = buffer
      }
    }
  }
}

