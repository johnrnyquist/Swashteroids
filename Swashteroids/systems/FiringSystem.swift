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
    private weak var creator: Creator?
    private var timeSinceLastShot = 0.25
    private weak var gunControlNodes: NodeList!
    private weak var scene: SKScene!

    init(creator: Creator) {
        self.creator = creator
    }

    override public func addToEngine(engine: Engine) {
        gunControlNodes = engine.getNodeList(nodeClassType: GunControlNode.self)
    }

    override public func update(time: TimeInterval) {
        timeSinceLastShot += time
        var node = gunControlNodes.head
        while node != nil {
            updateNode(node: node!, time: time)
            node = node!.next
        }
    }

    private func updateNode(node: Node, time: TimeInterval) {
        guard let motion = node[MotionComponent.self],
              let position = node[PositionComponent.self],
              let gun = node[GunComponent.self],
              let _ = node[TriggerDownComponent.self]
        else { return }
        if timeSinceLastShot >= gun.minimumShotInterval {
            creator?.createPlasmaTorpedo(gun, position, motion)
            timeSinceLastShot = 0
        }
    }

    override public func removeFromEngine(engine: Engine) {
        creator = nil
    }
}

