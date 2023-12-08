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

final class MotionComponent: Component {
    var velocity = CGPoint()
    var angularVelocity: Double
    var damping: Double

    init(velocityX: Double, velocityY: Double, angularVelocity: Double = 0.0, damping: Double = 50) {
        velocity = CGPoint(x: velocityX, y: velocityY)
        self.angularVelocity = angularVelocity
        self.damping = damping
    }
}

//_TODO: This class needs to be reworked_
final class MotionControlsComponent: Component {
    var accelerationRate: Double = 0
    var rotationRate: Double = 0

    init(left: UInt32, right: UInt32, accelerate: UInt32, accelerationRate: Double, rotationRate: Double) {
        self.accelerationRate = accelerationRate
        self.rotationRate = rotationRate
    }
}

/// Used by the flip button and in the FlipSystem.
/// Only one instance is needed. 
class FlipComponent: Component {
    static let instance = FlipComponent()
}

/// Used by the thrust button and in the ThrustSystem.
class LeftComponent: Component {
    static let instance = LeftComponent()
    let amount = 0.35
}

/// Used by the rotate right button and in the RightSystem.
class RightComponent: Component {
    static let instance = RightComponent()
    let amount = -0.35
}

/// Used to indicate the application of thrust. 
/// Per the ThrustNode, you need a WarpDriveComponent to apply thrust.
class ApplyThrustComponent: Component {
    static let instance = ApplyThrustComponent()
}
