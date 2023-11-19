import Foundation
import Swash


final class GunComponent: Component {
    var shooting = false
    var offsetFromParent: CGPoint
    var timeSinceLastShot: TimeInterval = 0
    var minimumShotInterval: TimeInterval = 0
    var bulletLifetime: TimeInterval = 0

    init(offsetX: Double, offsetY: Double, minimumShotInterval: TimeInterval, bulletLifetime: TimeInterval) {
        offsetFromParent = CGPoint(x: offsetX, y: offsetY)
        self.minimumShotInterval = minimumShotInterval
        self.bulletLifetime = bulletLifetime
    }
}
