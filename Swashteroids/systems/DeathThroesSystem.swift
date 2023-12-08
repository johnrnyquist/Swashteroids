//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import SpriteKit
import Swash


final class DeathThroesSystem: ListIteratingSystem {
    private weak var creator: Creator!

    init(creator: Creator) {
        self.creator = creator
        super.init(nodeClass: DeathThroesNode.self)
        nodeUpdateFunction = updateNode
    }

    func updateNode(node: Node, time: TimeInterval) {
        guard let deathComponent = node[DeathThroesComponent.self]
        else { return }
        deathComponent.countdown -= time
        if deathComponent.countdown <= 0,
           let entity = node.entity {
            creator.removeEntity(entity)
        }
    }

    override public func removeFromEngine(engine: Engine) {
        creator = nil
    }
}


