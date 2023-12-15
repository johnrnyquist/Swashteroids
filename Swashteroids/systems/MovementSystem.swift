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
        position.x += motion.velocity.x * time
        position.y += motion.velocity.y * time
        if (position.x < 0) {
            position.x += size.width
        }
        if (position.x > size.width) {
            position.x -= size.width
        }
        if (position.y < 0) {
            position.y += size.height
        }
        if (position.y > size.height) {
            position.y -= size.height
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
