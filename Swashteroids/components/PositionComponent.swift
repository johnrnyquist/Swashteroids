import Foundation
import Swash


final class PositionComponent: Component {
    var position: CGPoint
    var rotation: Double
    var zPosition: Layers

    init(x: Double, y: Double, z: Layers, rotation: Double = 0.0) {
        position = CGPoint(x: x, y: y)
        self.rotation = rotation
        zPosition = z
    }
}
