import SwiftUI
import StoreKit

private func openInstagram() {
  let url = URL(string: "https://instagram.com/tomokisun")!
  if UIApplication.shared.canOpenURL(url) {
    UIApplication.shared.open(url)
  }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate{
  func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
    if shortcutItem.type == "talk-to-founder" {
      openInstagram()
    }
    completionHandler(true)
  }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    if options.shortcutItem?.type == "talk-to-founder" {
      openInstagram()
    }
    let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
    config.delegateClass = SceneDelegate.self
    return config
  }
}

@main
struct FaceCutsApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @State private var camera: Camera = CameraModel()
  @Environment(\.requestReview) var requestReview
  
  var body: some Scene {
    WindowGroup {
      ContentView(camera: camera)
        .statusBarHidden()
        .persistentSystemOverlays(.hidden)
        .task {
          await camera.start()
          requestReview()
        }
    }
  }
}
