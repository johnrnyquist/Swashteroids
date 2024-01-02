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
import SpriteKit

final class ThrustSystem: ListIteratingSystem {
    init() {
        super.init(nodeClass: ThrustNode.self)
        nodeUpdateFunction = updateNode
    }

    private func updateNode(node: Node, time: TimeInterval) {
        guard let position = node[PositionComponent.self],
              let velocity = node[VelocityComponent.self],
              let movementRate = node[MovementRateComponent.self]
        else { return }
        let rotation = position.rotationDegrees * Double.pi / 180.0
        velocity.linearVelocity.x += cos(rotation) * movementRate.accelerationRate * time
        velocity.linearVelocity.y += sin(rotation) * movementRate.accelerationRate * time
    }
}