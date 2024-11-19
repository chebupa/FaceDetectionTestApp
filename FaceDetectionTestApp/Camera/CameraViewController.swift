////
////  CameraViewController.swift
////  FaceDetectionTestApp
////
////  Created by aristarh on 19.11.2024.
////
//
//import UIKit
//import AVFoundation
//
//// MARK: - ViewConroller
//
//class CameraViewController: UIViewController {
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
//    
//    // MARK: - View lifecycle
//    
//    override func viewWillAppear(_ animated: Bool) {
//        <#code#>
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//    
//    override func viewDidDisappear(_ animated: Bool) {
//        <#code#>
//    }
//}
//
//// MARK: - AVCaptureVideoDataOutputSampleBuffer delegate
//
//extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {}
//
//// MARK: - Camera setup
//
//private extension CameraViewController {}
