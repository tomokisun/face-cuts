import SwiftUI
import PhotosUI

struct ContentView: View {
  @State var camera: CameraModel
  
  var body: some View {
    PhotosPicker(selection: $camera.selection, matching: .images) {
      if let data = camera.backgroundImageData, let image = UIImage(data: data) {
        Image(uiImage: image)
          .resizable()
          .aspectRatio(contentMode: .fill)
          .ignoresSafeArea()
      } else {
        Color.green
          .ignoresSafeArea()
      }
    }
    .background(
      CameraPreview(session: camera.captureSession)
        .allowsHitTesting(false)
        .opacity(0.0)
    )
    .overlay {
      if let buffer = camera.pixelBuffer, let image = UIImage(pixelBuffer: buffer) {
        Image(uiImage: image)
          .resizable()
          .aspectRatio(contentMode: .fill)
          .ignoresSafeArea()
          .allowsHitTesting(false)
      }
    }
    .overlay(StatusView(status: camera.status))
    .onChange(of: camera.selection) { _, newValue in
      Task {
        try await camera.loadBackgroundImage()
      }
    }
  }
}
