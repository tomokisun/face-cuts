enum CameraError: Error {
  case videoDeviceUnavailable
  case audioDeviceUnavailable
  case addInputFailed
  case addOutputFailed
  case setupFailed
  case deviceChangeFailed
}
