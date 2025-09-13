import SwiftUI
import ARKit
import RealityKit
import Vision

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Configure and start the AR session
        let configuration = ARWorldTrackingConfiguration() // Changed from ARBodyTrackingConfiguration
        arView.session.run(configuration)
        
        arView.session.delegate = context.coordinator
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        let handPoseRequest = VNDetectHumanHandPoseRequest()

        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            let pixelBuffer = frame.capturedImage
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            
            do {
                try handler.perform([handPoseRequest])
                guard let observation = handPoseRequest.results?.first else {
                    return
                }
                // We have a hand observation, print to the console.
                print("Hand detected")
            } catch {
                print("Error performing hand pose request: \(error)")
            }
        }
    }
}