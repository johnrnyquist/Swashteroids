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

    func updateNode(node: Node, time: TimeInterval) {
        guard let position = node[PositionComponent.self],
              let velocity = node[VelocityComponent.self]
        else { return }
        position.x += velocity.linearVelocity.x * time
        position.y += velocity.linearVelocity.y * time
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
        position.rotationDegrees += velocity.angularVelocity * time
        if (velocity.dampening > 0) {
            let xDamp: Double = abs(cos(position.rotationDegrees) * velocity.dampening * time)
            let yDamp: Double = abs(cos(position.rotationDegrees) * velocity.dampening * time)
            if (velocity.linearVelocity.x > xDamp) {
                velocity.linearVelocity.x -= xDamp
            } else if (velocity.linearVelocity.x < -xDamp) {
                velocity.linearVelocity.x += xDamp
            } else {
                velocity.linearVelocity.x = 0
            }
            if (velocity.linearVelocity.y > yDamp) {
                velocity.linearVelocity.y -= yDamp
            } else if (velocity.linearVelocity.y < -yDamp) {
                velocity.linearVelocity.y += yDamp
            } else {
                velocity.linearVelocity.y = 0
            }
        }
    }
}
