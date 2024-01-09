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

final class FiringSystem: System {
    private weak var creator: TorpedoCreator?
    private weak var gunControlNodes: NodeList?
    private weak var engine: Engine?

    init(creator: TorpedoCreator) {
        self.creator = creator
    }

    override public func addToEngine(engine: Engine) {
        self.engine = engine
        gunControlNodes = engine.getNodeList(nodeClassType: GunControlNode.self)
    }

    override public func update(time: TimeInterval) {
        var node = gunControlNodes?.head
        while let currentNode = node {
            updateNode(node: currentNode, time: time)
            node = currentNode.next
        }
    }

    private func updateNode(node: Node, time: TimeInterval) {
        guard let velocity = node[VelocityComponent.self],
              let position = node[PositionComponent.self],
              let gun = node[GunComponent.self]
        else { return }
        gun.timeSinceLastShot += time
        if gun.timeSinceLastShot >= gun.minimumShotInterval {
            let pos = PositionComponent(x: position.x, y: position.y, z: .asteroids, rotationDegrees: position.rotationDegrees)
            creator?.createPlasmaTorpedo(gun, pos, velocity)
            gun.timeSinceLastShot = 0
        }
    }
}

