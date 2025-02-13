//
//  ContentView.swift
//  Punchie
//
//  Created by Ansheng Zhou on 2025-02-12.
//

import SwiftUI
import AVFoundation
import Vision

struct ContentView: View {
    @State private var isPunchDetected = false
    @State private var score = 0
    
    var body: some View {
        VStack {
            Text("Boxing Game")
                .font(.largeTitle)
                .padding()
            
            CameraView(isPunchDetected: $isPunchDetected, score: $score)
                .frame(height: 400)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.blue, lineWidth: 3))
                .padding()
            
            Text(isPunchDetected ? "🥊 Punch detected!" : "Throw a punch!")
                .font(.title)
                .foregroundColor(isPunchDetected ? .green : .gray)
                .padding()
            
            Text("Score: \(score)")
                .font(.title)
                .bold()
                .padding()
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var isPunchDetected: Bool
    @Binding var score: Int
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.isPunchDetected = $isPunchDetected
        controller.score = $score
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var isPunchDetected: Binding<Bool>?
    var score: Binding<Int>?
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

        // Run AVCaptureSession on a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let request = VNDetectHumanHandPoseRequest { request, error in
            guard let results = request.results as? [VNHumanHandPoseObservation], let firstHand = results.first else { return }
            
            do {
                let recognizedPoints = try firstHand.recognizedPoints(.all)
                if let wrist = recognizedPoints[.wrist], let indexTip = recognizedPoints[.indexTip] {
                    let movement = indexTip.location.y - wrist.location.y
                    DispatchQueue.main.async {
                        if movement > 0.2 {
                            self.isPunchDetected?.wrappedValue = true
                            self.score?.wrappedValue += 1
                        } else {
                            self.isPunchDetected?.wrappedValue = false
                        }
                    }
                }
            } catch {
                print("Error detecting hand movement: \(error)")
            }
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }
}

#Preview {
    ContentView()
}
