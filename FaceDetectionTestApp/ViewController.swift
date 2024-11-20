////
////  ViewController.swift
////  FaceDetectionTestApp
////
////  Created by aristarh on 20.10.2024.
////
//
//import UIKit
//import AVFoundation
//import Vision
//
//// MARK: - ViewContoller
//
//class ViewController: UIViewController {
//    
//    // MARK: - Properties
//    
//    let photoOutput = AVCapturePhotoOutput()
//    let videoOutput = AVCaptureVideoDataOutput()
//    var movieOutput: AVCaptureMovieFileOutput?
//    
//    var captureDevice: AVCaptureDevice? = nil
//    let captureSession = AVCaptureSession()
//    var previewLayer: AVCaptureVideoPreviewLayer?
////    var pivotPinchScale: CGFloat = 1
//    
//    private var drawings: [CAShapeLayer] = []
//    
//    // MARK: - ViewContoller appear
//    
//    override func viewWillAppear(_ animated: Bool) {
//        getCameraFrames()
//        captureSession.startRunning()
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupCameraDevice()
//    }
//    
//    override func viewDidDisappear(_ animated: Bool) {
//        captureSession.stopRunning()
////        movieOutput?.stopRecording()
//    }
//}
//
//// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
//
//extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
//    
//    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
//        detectFace(image: frame)
//        detectBodyPosition(image: frame)
//    }
//}
//
//// MARK: - Camera setup
//
//private extension ViewController {
//    
//    func getCameraFrames() {
//        videoOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString):NSNumber(value: kCVPixelFormatType_32BGRA)] as [String:Any]
//        videoOutput.alwaysDiscardsLateVideoFrames = true
//        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
//        if !captureSession.outputs.contains(videoOutput) {
//            captureSession.addOutput(videoOutput)
//        }
//        guard let connection = videoOutput.connection(with: .video), connection.isVideoOrientationSupported else { return }
//        connection.videoOrientation = .portrait
//    }
//    
//    func setupCameraDevice() {
//        
//        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
//            captureDevice = device
//        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
//            captureDevice = device
//        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
//            captureDevice = device
//            captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
//        } else {
//            fatalError("Missing expected back camera device")
//        }
//        
//        if let captureDevice = captureDevice {
//            captureSession.sessionPreset = AVCaptureSession.Preset.photo
//            
//            do {
//                try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
//                if captureSession.canAddOutput(photoOutput) {
//                    captureSession.addOutput(photoOutput)
//                }
//            } catch {
//                print(error.localizedDescription)
//            }
//            
//            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//            previewLayer?.frame = UIScreen.main.bounds
//            previewLayer?.videoGravity = .resizeAspectFill
//            self.view.layer.addSublayer(previewLayer!)
//            
//            captureSession.commitConfiguration()
//            
////            let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchToZoom))
////            self.view.addGestureRecognizer(pinchGestureRecognizer)
//        }
//        
//        if let audioDevice = AVCaptureDevice.default(for: .audio) {
//            do {
//                let audioInput = try AVCaptureDeviceInput(device: audioDevice)
//                if captureSession.canAddInput(audioInput) {
//                    captureSession.addInput(audioInput)
//                }
//            } catch {
//                printContent(error.localizedDescription)
//            }
//        }
//    }
//}
//// MARK: - Face recognition
//
//private extension ViewController {
//    
//    func detectFace(image: CVPixelBuffer) {
//        let faceDetectionRequest = VNDetectFaceLandmarksRequest { vnRequest, error in
//            DispatchQueue.main.async {
//                if let results = vnRequest.results as? [VNFaceObservation], results.count > 0 {
//                    self.handleFaceDetectionResults(observedFaces: results, pixelBuffer: image)
//                }
//            }
//        }
//        let imageResultHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .leftMirrored, options: [:])
//        try? imageResultHandler.perform([faceDetectionRequest])
//    }
//    
//    func handleFaceDetectionResults(observedFaces: [VNFaceObservation], pixelBuffer: CVPixelBuffer) {
//        
//        clearDrawings()
//        
//        guard let previewLayer = previewLayer else { return }
//        
//        for face in observedFaces {
//            let faceBoundingBoxOnScreen = previewLayer.layerRectConverted(fromMetadataOutputRect: face.boundingBox)
//            let faceBoundingBoxPath = CGPath(rect: faceBoundingBoxOnScreen, transform: nil)
//            let faceBoundingBoxShape = CAShapeLayer()
//            
//            faceBoundingBoxShape.strokeColor = UIColor.green.cgColor
//            faceBoundingBoxShape.path = faceBoundingBoxPath
//            faceBoundingBoxShape.fillColor = UIColor.clear.cgColor
//            view.layer.addSublayer(faceBoundingBoxShape)
//            drawings.append(faceBoundingBoxShape)
//        }
//    }
//}

import UIKit
import AVFoundation
import Vision

// MARK: - ViewController

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var bodyPoseRequest = VNDetectHumanBodyPoseRequest()
    private var faceDetectionRequest = VNDetectFaceLandmarksRequest()
    private let overlayLayer = CAShapeLayer()
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupOverlayLayer()
    }
}

// MARK: - Camera setup

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func setupCamera() {
        
        captureSession.sessionPreset = .hd4K3840x2160
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(videoDeviceInput) else {
            print("Cannot access camera")
            return
        }
        captureSession.addInput(videoDeviceInput)
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        guard captureSession.canAddOutput(videoOutput) else {
            print("Cannot add video output")
            return
        }
        captureSession.addOutput(videoOutput)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }
    
    func setupOverlayLayer() {
        
        overlayLayer.frame = view.bounds
        overlayLayer.strokeColor = UIColor.red.cgColor
        overlayLayer.lineWidth = 2.0
        view.layer.addSublayer(overlayLayer)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let bodyPoseRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
        let faceRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .leftMirrored, options: [:])
        
        // Body pose detection
        do {
            try bodyPoseRequestHandler.perform([bodyPoseRequest])
            guard let observations = bodyPoseRequest.results else { return }
            DispatchQueue.main.async {
                self.handleBodyPoseObservations(observations)
                
            }
        } catch {
            print("Failed to perform request: \(error)")
        }
        
        // Face detection
//        do {
//            try faceRequestHandler.perform([faceDetectionRequest])
//            guard let observations = faceDetectionRequest.results else { return }
//            DispatchQueue.main.async {
//                self.handleFaceObservations(observations)
//            }
//        } catch {
//            print("Failed to perform request: \(error)")
//        }
    }
}

// MARK: - Vision

private extension ViewController {
    
//    func detectFace(image: CVPixelBuffer) {
//        let faceDetectionRequest = VNDetectFaceLandmarksRequest { vnRequest, error in
//            DispatchQueue.main.async {
//                if let results = vnRequest.results as? [VNFaceObservation], results.count > 0 {
//                    self.handleFaceDetectionResults(observedFaces: results)
//                }
//            }
//        }
//        let imageResultHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .leftMirrored, options: [:])
//        try? imageResultHandler.perform([faceDetectionRequest])
//    }
    
    func handleFaceObservations(_ observations: [VNFaceObservation]) {
        overlayLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        for observation in observations {
            drawFaceBox(observedFace: observation)
        }
    }
    
    func drawFaceBox(observedFace: VNFaceObservation) {
        
        guard let previewLayer = previewLayer else { return }
        
        let faceBoundingBoxOnScreen = previewLayer.layerRectConverted(fromMetadataOutputRect: observedFace.boundingBox)
        let faceBoundingBoxPath = CGPath(rect: faceBoundingBoxOnScreen, transform: nil)
        let faceBoundingBoxShape = CAShapeLayer()
        
        faceBoundingBoxShape.strokeColor = UIColor.green.cgColor
        faceBoundingBoxShape.path = faceBoundingBoxPath
        faceBoundingBoxShape.fillColor = UIColor.clear.cgColor
        //            view.layer.addSublayer(faceBoundingBoxShape)
        //            drawings.append(faceBoundingBoxShape)
        overlayLayer.addSublayer(faceBoundingBoxShape)
    }
    
    func handleBodyPoseObservations(_ observations: [VNHumanBodyPoseObservation]) {
        
        overlayLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        for observation in observations {
            guard let recognizedPoints = try? observation.recognizedPoints(.all) else { continue }
            drawSkeleton(points: recognizedPoints)
        }
    }
    
    func drawSkeleton(points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        
        let path = UIBezierPath()
        
        // Skeleton connections (joints)
        let jointConnections: [(VNHumanBodyPoseObservation.JointName, VNHumanBodyPoseObservation.JointName)] = [
            (.neck, .nose), // Head
            (.neck, .leftShoulder), (.neck, .rightShoulder), // Shoulders
            (.leftShoulder, .leftElbow), (.leftElbow, .leftWrist), // Left arm
            (.rightShoulder, .rightElbow), (.rightElbow, .rightWrist), // Right arm
            (.neck, .root), // Spine
            (.root, .leftHip), (.root, .rightHip), // Hips
            (.leftHip, .leftKnee), (.leftKnee, .leftAnkle), // Left leg
            (.rightHip, .rightKnee), (.rightKnee, .rightAnkle) // Right leg
        ]
        
        // Transform and map points to screen space
        let screenPoints = points.compactMapValues { point -> CGPoint? in
            guard point.confidence > 0.5 else { return nil }
            let normalizedX = CGFloat(point.location.x)
            let normalizedY = CGFloat(1 - point.location.y) // Vision coordinates have Y inverted
            return CGPoint(x: normalizedX * view.bounds.width, y: normalizedY * view.bounds.height)
        }
        
        for (startJoint, endJoint) in jointConnections {
            guard let startPoint = screenPoints[startJoint], let endPoint = screenPoints[endJoint] else { continue }
            
            path.move(to: startPoint)
            path.addLine(to: endPoint)
        }
        
        // Draw the skeleton
        let skeletonLayer = CAShapeLayer()
        skeletonLayer.path = path.cgPath
        skeletonLayer.strokeColor = UIColor.green.cgColor
        skeletonLayer.lineWidth = 2.0
        overlayLayer.addSublayer(skeletonLayer)
        
        // Draw the keypoints
        for (_, point) in screenPoints {
            let circlePath = UIBezierPath(arcCenter: point, radius: 3.0, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
            let circleLayer = CAShapeLayer()
            circleLayer.path = circlePath.cgPath
            circleLayer.fillColor = UIColor.blue.cgColor
            overlayLayer.addSublayer(circleLayer)
        }
    }
}
