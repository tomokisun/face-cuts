import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate{
  func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
    let url = URL(string: "https://instagram.com/tomokisun")!
    UIApplication.shared.open(url)
    completionHandler(true)
  }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
    config.delegateClass = SceneDelegate.self
    return config
  }
}

@main
struct FaceCutsApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @State private var camera: Camera = CameraModel()
  
  var body: some Scene {
    WindowGroup {
      ContentView(camera: camera)
        .statusBarHidden()
        .task {
          await camera.start()
        }
        .onOpenURL { url in
          print(url)
        }
    }
  }
}
