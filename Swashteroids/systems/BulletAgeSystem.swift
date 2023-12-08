import Foundation
import Swash


final class BulletAgeSystem: ListIteratingSystem {
    private weak var creator: Creator!

    init(creator: Creator) {
        self.creator = creator
        super.init(nodeClass: BulletAgeNode.self)
        nodeUpdateFunction = updateNode
    }

	func updateNode(node: Node, time: TimeInterval) {
        guard let bulletComponent = node[PlasmaTorpedoComponent.self]
        else { return }
        bulletComponent.lifeRemaining -= time
        if bulletComponent.lifeRemaining <= 0,
           let entity = node.entity {
            creator.destroyEntity(entity)
        }
    }

    override public func removeFromEngine(engine: Engine) {
        creator = nil
    }
}



