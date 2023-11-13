import Foundation
import Swash


class PositionComponent: Component {
    var position: CGPoint
    var rotation: Double
    var zPosition: Layers

    init(x: Double, y: Double, z: Layers, rotation: Double) {
        position = CGPoint(x: x, y: y)
        self.rotation = rotation
        zPosition = z
    }
}
