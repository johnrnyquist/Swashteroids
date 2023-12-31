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
    var dampening: Double

    init(velocityX: Double, 
         velocityY: Double, 
         angularVelocity: Double = 0.0, 
         dampening: Double = 0.0, 
         scaleManager: ScaleManaging = ScaleManager.shared) 
    {
        velocity = CGPoint(x: velocityX * scaleManager.SCALE_FACTOR, 
                           y: velocityY * scaleManager.SCALE_FACTOR)
        self.angularVelocity = angularVelocity
        self.dampening = dampening
    }
}






