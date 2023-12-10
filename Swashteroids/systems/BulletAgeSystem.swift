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


final class BulletAgeSystem: ListIteratingSystem {
    private weak var engine: Engine!
    
    init() {
        super.init(nodeClass: BulletAgeNode.self)
        nodeUpdateFunction = updateNode
    }

    override func addToEngine(engine: Engine) { 
        super.addToEngine(engine: engine)
        self.engine = engine
    }

    func updateNode(node: Node, time: TimeInterval) {
        guard let bulletComponent = node[PlasmaTorpedoComponent.self]
        else { return }
        bulletComponent.lifeRemaining -= time
        if bulletComponent.lifeRemaining <= 0,
           let entity = node.entity {
            engine.removeEntity(entity: entity)
        }
    }
}



