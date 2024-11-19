import AVFoundation

actor CaptureService {
  private var isSetUp = false
  
  nonisolated let captureSession = AVCaptureSession()
  nonisolated let videoCapture = VideoCapture()
  
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
  
  var defaultCamera: AVCaptureDevice {
    get throws {
      guard let videoDevice = AVCaptureDevice.systemPreferredCamera else {
        throw CameraError.videoDeviceUnavailable
      }
      return videoDevice
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
      let camera = try defaultCamera
      
      try addInput(for: camera)
      
      try addOutput(videoCapture.output)
      
      captureSession.connections.forEach { $0.automaticallyAdjustsVideoMirroring = false }
      captureSession.connections.forEach { $0.isVideoMirrored = true }
      
      createRotationCoordinator(for: camera)
      
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
  
  private var rotationCoordinator: AVCaptureDevice.RotationCoordinator!
  private var rotationObservers = [AnyObject]()
  
  private func createRotationCoordinator(for device: AVCaptureDevice) {
    rotationCoordinator = AVCaptureDevice.RotationCoordinator(device: device, previewLayer: videoPreviewLayer)
    
    updatePreviewRotation(rotationCoordinator.videoRotationAngleForHorizonLevelPreview)
    updateCaptureRotation(rotationCoordinator.videoRotationAngleForHorizonLevelCapture)
    
    rotationObservers.removeAll()
    
    rotationObservers.append(
      rotationCoordinator.observe(\.videoRotationAngleForHorizonLevelPreview, options: .new) { [weak self] _, change in
        guard let self, let angle = change.newValue else { return }
        Task { await self.updatePreviewRotation(angle) }
      }
    )
    
    rotationObservers.append(
      rotationCoordinator.observe(\.videoRotationAngleForHorizonLevelCapture, options: .new) { [weak self] _, change in
        guard let self, let angle = change.newValue else { return }
        Task { await self.updateCaptureRotation(angle) }
      }
    )
  }
  
  private func updatePreviewRotation(_ angle: CGFloat) {
    let previewLayer = videoPreviewLayer
    Task { @MainActor in
      previewLayer.connection?.videoRotationAngle = angle
    }
  }
  
  private func updateCaptureRotation(_ angle: CGFloat) {
    videoCapture.setVideoRotationAngle(angle)
  }
  
  private var videoPreviewLayer: AVCaptureVideoPreviewLayer {
    guard let previewLayer = captureSession.connections.compactMap(\.videoPreviewLayer).first else {
      fatalError("The app is misconfigured. The capture session should have a connection to a preview layer.")
    }
    return previewLayer
  }
}
