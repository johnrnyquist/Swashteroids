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

class FlipComponent: Component {
    static let instance = FlipComponent()
}

class LeftComponent: Component {
    static let instance = LeftComponent()
    let amount = 0.35
}

class RightComponent: Component {
    static let instance = RightComponent()
    let amount = -0.35
}

class ThrustComponent: Component {
    static let instance = ThrustComponent()
}
