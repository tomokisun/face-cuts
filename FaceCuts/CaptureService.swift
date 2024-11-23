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
      let device = try deviceLookup.frontCamera
      let input = try addInput(for: device)
      try addOutput(videoCapture.output)
      addConnection(input: input, output: videoCapture.output, device: device)
      
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
}

extension CaptureService {
  @discardableResult
  private func addInput(for device: AVCaptureDevice) throws -> AVCaptureDeviceInput {
    let input = try AVCaptureDeviceInput(device: device)
    if captureSession.canAddInput(input) {
      captureSession.addInputWithNoConnections(input)
    } else {
      throw CameraError.addInputFailed
    }
    return input
  }
  
  private func addOutput(_ output: AVCaptureOutput) throws {
    if captureSession.canAddOutput(output) {
      captureSession.addOutputWithNoConnections(output)
    } else {
      throw CameraError.addOutputFailed
    }
  }
  
  private func addConnection(input: AVCaptureDeviceInput, output: AVCaptureOutput, device: AVCaptureDevice) {
    let port = input.ports(for: .video, sourceDeviceType: device.deviceType, sourceDevicePosition: device.position)
    let connection = AVCaptureConnection(inputPorts: port, output: output)
    connection.automaticallyAdjustsVideoMirroring = false
    connection.isVideoMirrored = true
    connection.videoRotationAngle = 90
    
    if captureSession.canAddConnection(connection) {
      captureSession.addConnection(connection)
    }
  }
}
