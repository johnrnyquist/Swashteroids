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

final class GunComponent: Component {
    var offsetFromParent =  CGPoint(x: 21, y: 0)
    var minimumShotInterval: TimeInterval = 0.25
    var torpedoLifetime: TimeInterval = 2.0

    init(offsetX: Double, offsetY: Double, minimumShotInterval: TimeInterval, torpedoLifetime: TimeInterval) {
        offsetFromParent = CGPoint(x: offsetX, y: offsetY)
        self.minimumShotInterval = minimumShotInterval
        self.torpedoLifetime = torpedoLifetime
    }
}
