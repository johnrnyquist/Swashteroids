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

// GunComponent
final class GunComponent: Component {
//    var shooting = false
    var offsetFromParent: CGPoint
    var timeSinceLastShot: TimeInterval = 0
    var minimumShotInterval: TimeInterval = 0
    var torpedoLifetime: TimeInterval = 0

    init(offsetX: Double, offsetY: Double, minimumShotInterval: TimeInterval, torpedoLifetime: TimeInterval) {
        offsetFromParent = CGPoint(x: offsetX, y: offsetY)
        self.minimumShotInterval = minimumShotInterval
        self.torpedoLifetime = torpedoLifetime
    }
}
