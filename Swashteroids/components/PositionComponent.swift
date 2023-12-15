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
    var x: Double {
        get { position.x }
        set { position = CGPoint(x: newValue, y: y) }
    }
    var y: Double {
        get { position.y }
        set { position = CGPoint(x: x, y: newValue) }
    }
    var position: CGPoint
    var rotation: Double
    var layer: Layer

    init(x: Double, y: Double, z: Layer, rotation: Double = 0.0) {
        position = CGPoint(x: x, y: y)
        self.rotation = rotation
        layer = z
    }
}
