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

final class AccelerometerSystem: ListIteratingSystem {
    init() {
        super.init(nodeClass: AccelerometerNode.self)
        nodeUpdateFunction = updateNode
    }

    private func updateNode(node: Node, time: TimeInterval) {
        guard let input = node[InputComponent.self],
              input.rotate.isDown,
              let position = node[PositionComponent.self],
              let control = node[MovementRateComponent.self]
        else { return }
        position.rotationDegrees += control.rotationRate * (input.rotate.amount * 0.05)
    }
}
