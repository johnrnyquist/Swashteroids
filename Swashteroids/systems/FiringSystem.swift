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

final class FiringSystem: ListIteratingSystem {
    private weak var creator: Creator?
    private weak var torpedoes: NodeList!

    init(creator: Creator) {
        self.creator = creator
        super.init(nodeClass: GunControlNode.self)
        nodeUpdateFunction = updateNode
    }

    override public func addToEngine(engine: Engine) {
        super.addToEngine(engine: engine)
        torpedoes = engine.getNodeList(nodeClassType: PlasmaTorpedoCollisionNode.self)
    }

    private func updateNode(node: Node, time: TimeInterval) {
        guard let motion = node[MotionComponent.self],
              let position = node[PositionComponent.self],
              let gun = node[GunComponent.self]
        else { return }
        gun.timeSinceLastShot += time
        if gun.timeSinceLastShot >= gun.minimumShotInterval {
            creator?.createUserTorpedo(gun, position, motion)
            gun.timeSinceLastShot = 0
        }
    }

    override public func removeFromEngine(engine: Engine) {
        creator = nil
        torpedoes = nil
    }
}

