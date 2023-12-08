//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

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
