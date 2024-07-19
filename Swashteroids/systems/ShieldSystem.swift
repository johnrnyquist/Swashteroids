//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import Swash
import Foundation.NSDate

final class ShieldSystem: ListIteratingSystem {
    private weak var shieldNodes: NodeList?
    private weak var playerNodes: NodeList?

    init() {
        super.init(nodeClass: ShieldNode.self)
        nodeUpdateFunction = updateNode
    }

    override func addToEngine(engine: Engine) {
        super.addToEngine(engine: engine)
        shieldNodes = engine.getNodeList(nodeClassType: ShieldNode.self)
        playerNodes = engine.getNodeList(nodeClassType: PlayerNode.self)
    }

    func updateNode(node: Node, time: TimeInterval) {
        guard let shieldPosition = node[PositionComponent.self],
              let playerPosition = playerNodes?.head?.entity?[PositionComponent.self],
              let sprite = node[DisplayComponent.self]?.sprite,
              let shield = node[ShieldComponent.self]
        else { return }
        shieldPosition.x = playerPosition.x
        shieldPosition.y = playerPosition.y
        sprite.alpha = CGFloat(shield.strength) / CGFloat(shield.maxCollisions)
    }
}

