import SwiftUI
@preconcurrency import AVFoundation

struct CameraPreview: UIViewRepresentable {
  private let session: AVCaptureSession
  
  init(session: AVCaptureSession) {
    self.session = session
  }
  
  func makeUIView(context: Context) -> PreviewView {
    let preview = PreviewView()
    preview.setSession(session)
    return preview
  }
  
  func updateUIView(_ previewView: PreviewView, context: Context) {
  }
  
  class PreviewView: UIView {
    init() {
      super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    override class var layerClass: AnyClass {
      AVCaptureVideoPreviewLayer.self
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer {
      layer as! AVCaptureVideoPreviewLayer
    }
    
    nonisolated func setSession(_ session: AVCaptureSession) {
      Task { @MainActor in
        previewLayer.session = session
      }
    }
  }
}
