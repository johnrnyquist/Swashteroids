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

final class MotionControlsComponent: Component {
    var accelerationRate: Double = 0
    var rotationRate: Double = 0

    init(accelerationRate: Double, 
         rotationRate: Double, 
         scaleManager: ScaleManaging = ScaleManager.shared) 
    {
        self.accelerationRate = accelerationRate * scaleManager.SCALE_FACTOR
        self.rotationRate = rotationRate
    }
}
