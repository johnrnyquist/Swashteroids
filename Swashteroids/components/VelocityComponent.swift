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

final class VelocityComponent: Component {
    var linearVelocity = CGPoint()
    var x: Double {
        get { Double(linearVelocity.x) }
        set { linearVelocity.x = newValue }
    }
    var y: Double {
        get { Double(linearVelocity.y) }
        set { linearVelocity.y = newValue }
    }
    var angularVelocity: Double
    var dampening: Double
    var wraps: Bool
    var base: Double
    var exit: Double

    init(velocityX: Double,
         velocityY: Double,
         angularVelocity: Double = 0.0,
         dampening: Double = 0.0,
         wraps: Bool = true,
         base: Double? = nil,
         scaleManager: ScaleManaging = ScaleManager.shared) {
        linearVelocity = CGPoint(x: velocityX * scaleManager.SCALE_FACTOR,
                                 y: velocityY * scaleManager.SCALE_FACTOR)
        self.angularVelocity = angularVelocity
        self.dampening = dampening
        self.wraps = wraps
        if let base { self.base = base * scaleManager.SCALE_FACTOR }
        else { self.base = velocityX * scaleManager.SCALE_FACTOR }
        exit = 300 * scaleManager.SCALE_FACTOR
    }
}






