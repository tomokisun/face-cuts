import SwiftUI

@main
struct FaceCutsApp: App {
  @State private var camera = CameraModel()

  var body: some Scene {
    WindowGroup {
      ContentView(camera: camera)
        .statusBarHidden()
        .task {
          await camera.start()
        }
    }
  }
}
