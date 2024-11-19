import UIKit

extension UIImage {
  convenience init?(pixelBuffer: CVPixelBuffer) {
    let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
    let context = CIContext()
    
    guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
    self.init(cgImage: cgImage)
  }
}
