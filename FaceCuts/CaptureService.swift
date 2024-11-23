import AVFoundation

actor CaptureService {
  private var isSetUp = false
  
  nonisolated let captureSession = AVCaptureSession()
  nonisolated let videoCapture = VideoCapture()
  
  private let deviceLookup = DeviceLookup()
  
  var isAuthorized: Bool {
    get async {
      let status = AVCaptureDevice.authorizationStatus(for: .video)
      var isAuthorized = status == .authorized
      if status == .notDetermined {
        isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
      }
      return isAuthorized
    }
  }
  
  func start() async throws {
    guard await isAuthorized, !captureSession.isRunning else { return }
    try setUpSession()
    captureSession.startRunning()
  }
  
  private func setUpSession() throws {
    guard !isSetUp else { return }
    
    do {
      let camera = try deviceLookup.frontCamera
      
      try addInput(for: camera)
      
      try addOutput(videoCapture.output)

      captureSession.connections.forEach {
        $0.automaticallyAdjustsVideoMirroring = false
        $0.isVideoMirrored = true
        $0.videoRotationAngle = 90
      }
      
      isSetUp = true
    } catch {
      throw CameraError.setupFailed
    }
  }
  
  @discardableResult
  private func addInput(for device: AVCaptureDevice) throws -> AVCaptureDeviceInput {
    let input = try AVCaptureDeviceInput(device: device)
    if captureSession.canAddInput(input) {
      captureSession.addInput(input)
    } else {
      throw CameraError.addInputFailed
    }
    return input
  }
  
  private func addOutput(_ output: AVCaptureOutput) throws {
    if captureSession.canAddOutput(output) {
      captureSession.addOutput(output)
    } else {
      throw CameraError.addOutputFailed
    }
  }
}
