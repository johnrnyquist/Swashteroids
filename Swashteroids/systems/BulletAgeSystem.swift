import Foundation
import Swash


class BulletAgeSystem: ListIteratingSystem {
    private var creator: EntityCreator

    init(creator: EntityCreator) {
        self.creator = creator
        super.init(nodeClass: BulletAgeNode.self)
        nodeUpdateFunction = updateNode
    }

    private func updateNode(node: Node, time: TimeInterval) {
        guard let bulletComponent = node[BulletComponent.self]
        else { return }
        bulletComponent.lifeRemaining -= time
        if bulletComponent.lifeRemaining <= 0,
           let entity = node.entity {
            creator.destroyEntity(entity)
        }
    }
}



