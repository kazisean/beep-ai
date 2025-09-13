import SwiftUI
import RealityKit
import ARKit

struct ContentView: View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        arView.session.run(config, options: [])
        
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap)))
        context.coordinator.arView = arView
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        weak var arView: ARView?
        
        @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
            guard let arView = arView else { return }
            
            let location = recognizer.location(in: arView)
            let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
            
            if let firstResult = results.first {
                let anchor = ARAnchor(transform: firstResult.worldTransform)
                arView.session.add(anchor: anchor)
                
                let box = MeshResource.generateBox(size: 0.2)
                let material = SimpleMaterial(color: .blue.withAlphaComponent(0.5), isMetallic: false)
                let modelEntity = ModelEntity(mesh: box, materials: [material])
                
                let text = MeshResource.generateText("Hello World", extrusionDepth: 0.02, font: .systemFont(ofSize: 0.08))
                let textMaterial = SimpleMaterial(color: .red, isMetallic: false)
                let textEntity = ModelEntity(mesh: text, materials: [textMaterial])
                
                textEntity.position.y = 0.1
                
                let anchorEntity = AnchorEntity(anchor: anchor)
                anchorEntity.addChild(modelEntity)
                anchorEntity.addChild(textEntity)
                
                arView.scene.addAnchor(anchorEntity)
            }
        }
    }
}

#Preview {
    ContentView()
}
