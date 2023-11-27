import Foundation
import Swash


final class MovementSystem: ListIteratingSystem {
    var size: CGSize

    init(size: CGSize) {
        self.size = size
		super.init(nodeClass: MovementNode.self)
        nodeUpdateFunction = updateNode
    }

    private func updateNode(node: Node, time: TimeInterval) {
        guard let position = node[PositionComponent.self],
              let motion = node[MotionComponent.self]
        else { return }
        position.position.x += motion.velocity.x * time
        position.position.y += motion.velocity.y * time
        if (position.position.x < 0) {
            position.position.x += size.width
        }
        if (position.position.x > size.width) {
            position.position.x -= size.width
        }
        if (position.position.y < 0) {
            position.position.y += size.height
        }
        if (position.position.y > size.height) {
            position.position.y -= size.height
        }
        position.rotation += motion.angularVelocity * time
        if (motion.damping > 0) {
            let xDamp: Double = abs(cos(position.rotation) * motion.damping * time)
            let yDamp: Double = abs(cos(position.rotation) * motion.damping * time)
            if (motion.velocity.x > xDamp) {
                motion.velocity.x -= xDamp
            } else if (motion.velocity.x < -xDamp) {
                motion.velocity.x += xDamp
            } else {
                motion.velocity.x = 0
            }
            if (motion.velocity.y > yDamp) {
                motion.velocity.y -= yDamp
            } else if (motion.velocity.y < -yDamp) {
                motion.velocity.y += yDamp
            } else {
                motion.velocity.y = 0
            }
        }
    }
}
