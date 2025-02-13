//
//  CameraView.swift
//  Punchie
//
//  Created by Ansheng Zhou on 2025-02-13.
//

import SwiftUI
import AVFoundation
import Vision

// Camera View - Handles motion capture and detection
struct CameraView: UIViewControllerRepresentable {
    @Binding var isPunchDetected: Bool
    @Binding var score: Int
    @Binding var level: Int

    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.isPunchDetected = $isPunchDetected
        controller.score = $score
        controller.level = $level
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

// Camera View Controller - Manages AVCaptureSession and Vision processing
class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var isPunchDetected: Binding<Bool>?
    var score: Binding<Int>?
    var level: Binding<Int>?
    
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    private func setupCamera() {
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            captureSession.addInput(input)
        } catch {
            print("Camera error: \(error.localizedDescription)")
        }
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(videoOutput)

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNDetectHumanBodyPoseRequest { request, error in
            guard let results = request.results as? [VNHumanBodyPoseObservation], let firstBody = results.first else { return }

            do {
                let recognizedPoints = try firstBody.recognizedPoints(.all)
                if let wrist = recognizedPoints[VNHumanBodyPoseObservation.JointName.rightWrist],
                   let elbow = recognizedPoints[VNHumanBodyPoseObservation.JointName.rightElbow] {
                    let movement = wrist.location.y - elbow.location.y
                    DispatchQueue.main.async {
                        if movement > 0.2 {
                            self.isPunchDetected?.wrappedValue = true
                            self.score?.wrappedValue += 1

                            // Level Progression
                            if let currentScore = self.score?.wrappedValue, let currentLevel = self.level?.wrappedValue {
                                let requiredScore = 10 + (currentLevel - 1) * 5
                                if currentScore >= requiredScore {
                                    self.level?.wrappedValue += 1
                                }
                            }
                        } else {
                            self.isPunchDetected?.wrappedValue = false
                        }
                    }
                }
            } catch {
                print("Error detecting body movement: \(error)")
            }
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }
}
