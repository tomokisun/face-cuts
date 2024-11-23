import SwiftUI
import PhotosUI

struct ContentView: View {
  @State var camera: Camera
  
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
    .overlay {
      if let buffer = camera.pixelBuffer, let image = UIImage(pixelBuffer: buffer) {
        GeometryReader { proxy in
          VStack(spacing: 0) {
            Spacer()
            Image(uiImage: image)
              .resizable()
              .aspectRatio(contentMode: .fill)
              .allowsHitTesting(false)
              .frame(height: proxy.size.height / 2)
          }
        }
        .ignoresSafeArea()
      }
    }
    .overlay(StatusView(status: camera.status))
    .sensoryFeedback(.selection, trigger: camera.selection)
    .onChange(of: camera.selection) { _, newValue in
      Task {
        try await camera.loadBackgroundImage()
      }
    }
  }
}

#Preview {
  ContentView(camera: PreviewCameraModel())
}
