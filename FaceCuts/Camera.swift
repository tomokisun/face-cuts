import SwiftUI
import PhotosUI
import CoreVideo
import AVFoundation

protocol Camera {
  var status: CameraStatus { get }
  
  var pixelBuffer: CVPixelBuffer? { get }
  
  var selection: PhotosPickerItem? { get set }
  
  var backgroundImageData: Data? { get }
  
  var captureSession: AVCaptureSession { get }
  
  func start() async
  
  func loadBackgroundImage() async throws
}

class PreviewCameraModel: Camera {
  var status: CameraStatus
  
  var pixelBuffer: CVPixelBuffer?
  
  var selection: PhotosPickerItem?
  
  var backgroundImageData: Data?
  
  var captureSession = AVCaptureSession()
  
  init(status: CameraStatus = .unknown) {
    self.status = status
  }
  
  func start() async {
    
  }
  
  func loadBackgroundImage() async throws {
    
  }
}
