import AVFoundation
import CoreImage
import Vision

final class VideoCapture: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
  let output = AVCaptureVideoDataOutput()
  
  @Published private(set) var currentPixelBuffer: CVPixelBuffer?
  
  override init() {
    super.init()
    
    let queue = DispatchQueue(label: "video")
    output.setSampleBufferDelegate(self, queue: queue)
  }
  
  func setVideoRotationAngle(_ angle: CGFloat) {
    output.connection(with: .video)?.videoRotationAngle = angle
  }
  
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
    let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
    
    let imageRequestHandler = ImageRequestHandler(pixelBuffer)
    let request = GenerateForegroundInstanceMaskRequest()
    Task {
      if let result = try? await request.perform(on: ciImage) {
        currentPixelBuffer = try? result.generateMaskedImage(
          for: result.allInstances,
          imageFrom: imageRequestHandler,
          croppedToInstancesExtent: false
        )
      }
    }
  }
}
