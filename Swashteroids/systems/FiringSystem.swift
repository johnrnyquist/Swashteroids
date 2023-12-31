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
    var timeSinceLastShot = 0.25
    private weak var creator: TorpedoCreator?
    private weak var gunControlNodes: NodeList!

    init(creator: TorpedoCreator) {
        self.creator = creator
    }

    override public func addToEngine(engine: Engine) {
        gunControlNodes = engine.getNodeList(nodeClassType: GunControlNode.self)
    }

    override public func update(time: TimeInterval) {
        timeSinceLastShot += time
        var node = gunControlNodes.head
        while let currentNode = node {
            updateNode(node: currentNode, time: time)
            node = currentNode.next
        }
    }

    private func updateNode(node: Node, time: TimeInterval) {
        guard let velocity = node[VelocityComponent.self],
              let position = node[PositionComponent.self],
              let gun = node[GunComponent.self],
              let _ = node[FireDownComponent.self]
        else { return }
        if timeSinceLastShot >= gun.minimumShotInterval {
            creator?.createPlasmaTorpedo(gun, position, velocity)
            timeSinceLastShot = 0
        }
    }
}

