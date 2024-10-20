//
//  ViewController.swift
//  FaceDetectionTestApp
//
//  Created by aristarh on 20.10.2024.
//

import UIKit
import AVFoundation
import Vision

// MARK: - ViewContoller

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    let photoOutput = AVCapturePhotoOutput()
    let videoOutput = AVCaptureVideoDataOutput()
    var movieOutput: AVCaptureMovieFileOutput?
    
    var captureDevice: AVCaptureDevice? = nil
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
//    var pivotPinchScale: CGFloat = 1
    
    private var drawings: [CAShapeLayer] = []
    
    // MARK: - ViewContoller appear
    
    override func viewWillAppear(_ animated: Bool) {
        getCameraFrames()
        captureSession.startRunning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCameraDevice()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        captureSession.stopRunning()
//        movieOutput?.stopRecording()
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        detectFace(image: frame)
//        detectBodyPosition(image: frame)
    }
}

// MARK: - Camera setup

private extension ViewController {
    
    func getCameraFrames() {
        videoOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString):NSNumber(value: kCVPixelFormatType_32BGRA)] as [String:Any]
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
        if !captureSession.outputs.contains(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        guard let connection = videoOutput.connection(with: .video), connection.isVideoOrientationSupported else { return }
        connection.videoOrientation = .portrait
    }
    
    func setupCameraDevice() {
        
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            captureDevice = device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            captureDevice = device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
//            captureDevice = device
            captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        } else {
            fatalError("Missing expected back camera device")
        }
        
        if let captureDevice = captureDevice {
            captureSession.sessionPreset = AVCaptureSession.Preset.photo
            
            do {
                try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
                if captureSession.canAddOutput(photoOutput) {
                    captureSession.addOutput(photoOutput)
                }
            } catch {
                print("CAPTURE DEVICE INPUT ADDING FAILED")
//                print(error.localizedDescription)
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer?.frame  = UIScreen.main.bounds
            previewLayer?.videoGravity = .resizeAspectFill
            self.view.layer.addSublayer(previewLayer!)
            
            captureSession.commitConfiguration()
            
//            let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchToZoom))
//            self.view.addGestureRecognizer(pinchGestureRecognizer)
        }
        
        if let audioDevice = AVCaptureDevice.default(for: .audio) {
            do {
                let audioInput = try AVCaptureDeviceInput(device: audioDevice)
                if captureSession.canAddInput(audioInput) {
                    captureSession.addInput(audioInput)
                }
            } catch {
                print("AUDIO DEVICE INPUT FAILED")
//                printContent(error.localizedDescription)
            }
        }
    }
}

// MARK: - Vision -

// MARK: - Face recognition

private extension ViewController {
    
    func clearDrawings() {
        for drawing in drawings {
            drawing.removeFromSuperlayer()
        }
        drawings.removeAll()
    }
    
    func detectFace(image: CVPixelBuffer) {
        let faceDetectionRequest = VNDetectFaceLandmarksRequest { vnRequest, error in
            DispatchQueue.main.async {
                if let results = vnRequest.results as? [VNFaceObservation], results.count > 0 {
                    self.handleFaceDetectionResults(observedFaces: results, pixelBuffer: image)
                }
            }
        }
        let imageResultHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .leftMirrored, options: [:])
        try? imageResultHandler.perform([faceDetectionRequest])
    }
    
    func handleFaceDetectionResults(observedFaces: [VNFaceObservation], pixelBuffer: CVPixelBuffer) {
        
        clearDrawings()
        
        guard let previewLayer = previewLayer else { return }
        
        for face in observedFaces {
//            print(face)
            let faceBoundingBoxOnScreen = previewLayer.layerRectConverted(fromMetadataOutputRect: face.boundingBox)
            let faceBoundingBoxPath = CGPath(rect: faceBoundingBoxOnScreen, transform: nil)
            let faceBoundingBoxShape = CAShapeLayer()
            
            faceBoundingBoxShape.strokeColor = UIColor.green.cgColor
            faceBoundingBoxShape.path = faceBoundingBoxPath
            faceBoundingBoxShape.fillColor = UIColor.clear.cgColor
            view.layer.addSublayer(faceBoundingBoxShape)
            drawings.append(faceBoundingBoxShape)
        }
    }
}

// MARK: - Body pose recognition

private extension ViewController {
    
    func detectBodyPosition(image: CVPixelBuffer) {
        let bodyPositionDetectionRequest = VNDetectHumanBodyPoseRequest { vnRequest, error in
            DispatchQueue.main.async {
                if let results = vnRequest.results as? [VNHumanBodyPoseObservation], results.count > 0 {
                    self.handleBodyPoseDetectionResults(bodyPoses: results, pixelBuffer: image)
                }
            }
        }
    }
    
    func handleBodyPoseDetectionResults(bodyPoses: [VNHumanBodyPoseObservation], pixelBuffer: CVPixelBuffer) {
        
        clearDrawings()
        
        guard let previewLayer = previewLayer else { return }
        
        for bodyPose in bodyPoses {
//            view.dra
        }
        
        
    }
}
