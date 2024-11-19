import SwiftUI

struct StatusView: View {
  let status: CameraStatus
  let handled: [CameraStatus] = [.unauthorized, .failed]
  
  var body: some View {
    if handled.contains(status) {
      Rectangle()
        .fill(Color(white: 0.0, opacity: 0.5))
      
      Text(message)
        .font(.headline)
        .foregroundColor(color == .yellow ? .init(white: 0.25) : .white)
        .padding()
        .background(color)
        .cornerRadius(8.0)
        .frame(maxWidth: 600)
    }
  }
  
  var color: Color {
    switch status {
    case .unauthorized:
      return .red
    case .failed:
      return .orange
    default:
      return .clear
    }
  }
  
  var message: String {
    switch status {
    case .unauthorized:
      return "You haven't authorized FaceCuts to use the camera. Change these settings in Settings -> Privacy & Security"
    case .failed:
      return "The camera failed to start. Please try relaunching the app."
    default:
      return ""
    }
  }
}
