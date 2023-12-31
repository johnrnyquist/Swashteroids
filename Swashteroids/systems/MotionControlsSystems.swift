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

final class LeftSystem: ListIteratingSystem {
    init() {
        super.init(nodeClass: LeftNode.self)
        nodeUpdateFunction = updateNode
    }

    private func updateNode(node: Node, time: TimeInterval) {
        guard let position = node[PositionComponent.self],
              let control = node[MotionControlsComponent.self],
              let left = node[LeftComponent.self]
        else { return }
        position.rotation += control.rotationRate * (left.amount * 0.05)
    }
}

final class RightSystem: ListIteratingSystem {
    init() {
        super.init(nodeClass: RightNode.self)
        nodeUpdateFunction = updateNode
    }

    private func updateNode(node: Node, time: TimeInterval) {
        guard let position = node[PositionComponent.self],
              let control = node[MotionControlsComponent.self],
              let right = node[RightComponent.self]
        else { return }
        position.rotation += control.rotationRate * (right.amount * 0.05)
    }
}

final class ThrustSystem: ListIteratingSystem {
    init() {
        super.init(nodeClass: ThrustNode.self)
        nodeUpdateFunction = updateNode
    }

    private func updateNode(node: Node, time: TimeInterval) {
        guard let position = node[PositionComponent.self],
              let motion = node[MotionComponent.self],
              let control = node[MotionControlsComponent.self]
        else { return }
        let rot = position.rotation * Double.pi / 180.0
        motion.velocity.x += cos(rot) * control.accelerationRate * time
        motion.velocity.y += sin(rot) * control.accelerationRate * time
    }
}

final class FlipSystem: ListIteratingSystem {
    init() {
        super.init(nodeClass: FlipNode.self)
        nodeUpdateFunction = updateNode
    }

    private func updateNode(node: Node, time: TimeInterval) {
        guard let position = node[PositionComponent.self],
              let _ = node[FlipComponent.self] else { return }
        position.rotation += 180
        node.entity?.remove(componentClass: FlipComponent.self)
    }
}

