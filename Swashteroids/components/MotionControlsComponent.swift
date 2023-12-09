//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import Swash

//_TODO: This class needs to be reworked_
final class MotionControlsComponent: Component {
    var accelerationRate: Double = 0
    var rotationRate: Double = 0

    init(left: UInt32, right: UInt32, accelerate: UInt32, accelerationRate: Double, rotationRate: Double) {
        self.accelerationRate = accelerationRate
        self.rotationRate = rotationRate
    }
}