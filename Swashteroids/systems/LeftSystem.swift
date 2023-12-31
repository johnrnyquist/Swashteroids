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
        position.rotationDegrees += control.rotationRate * left.amount
    }
}