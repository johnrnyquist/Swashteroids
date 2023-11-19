import Foundation
import Swash


final class MotionComponent: Component {
    var velocity = CGPoint()
    var angularVelocity: Double
    var damping: Double

    init(velocityX: Double, velocityY: Double, angularVelocity: Double = 0.0, damping: Double = 0.0) {
        velocity = CGPoint(x: velocityX, y: velocityY)
        self.angularVelocity = angularVelocity
        self.damping = damping
    }
}
