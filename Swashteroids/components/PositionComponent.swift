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
    var layer: Layer
    var point: CGPoint
    var rotationDegrees: Double
    var x: Double {
        get { point.x }
        set { point = CGPoint(x: newValue, y: y) }
    }
    var y: Double {
        get { point.y }
        set { point = CGPoint(x: x, y: newValue) }
    }
    var rotationRadians: Double {
        get { rotationDegrees * Double.pi / 180.0 }
        set { rotationDegrees = newValue * 180.0 / Double.pi }
    }

    init(x: Double, y: Double, z: CGFloat, rotationDegrees: Double = 0.0) {
        point = CGPoint(x: x, y: y)
        self.rotationDegrees = rotationDegrees
        layer = z
    }
}
