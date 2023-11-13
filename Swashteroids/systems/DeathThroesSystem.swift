import SpriteKit
import Swash


class DeathThroesSystem: ListIteratingSystem {
    private var creator: EntityCreator

    init(creator: EntityCreator) {
        self.creator = creator
        super.init(nodeClass: DeathThroesNode.self)
        nodeUpdateFunction = updateNode
    }

    private func updateNode(node: Node, time: TimeInterval) {
        guard let deathComponent = node[DeathThroesComponent.self]
        else { return }
        deathComponent.countdown -= time
        if deathComponent.countdown <= 0,
           let entity = node.entity {
            creator.destroyEntity(entity)
        }
    }
}


