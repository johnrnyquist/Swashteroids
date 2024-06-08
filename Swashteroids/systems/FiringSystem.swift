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
    typealias Creator = TorpedoCreatorUseCase & PowerUpCreatorUseCase
    private weak var creator: Creator?
    private weak var firingNodes: NodeList?
    private weak var engine: Engine?
    
    init(creator: Creator) {
        self.creator = creator
    }

    override public func addToEngine(engine: Engine) {
        firingNodes = engine.getNodeList(nodeClassType: FiringNode.self)
        self.engine = engine
    }

    override public func update(time: TimeInterval) {
        var node = firingNodes?.head
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
        node.entity?.remove(componentClass: FireDownComponent.self)
        let pos = PositionComponent(x: position.x, y: position.y, z: .asteroids, rotationDegrees: position.rotationDegrees)
        creator?.createTorpedo(gun, pos, velocity)
        gun.numTorpedoes -= 1
        if let appState = engine?.appStateComponent {
            appState.numTorpedoesPlayerFired += 1
        }
    }
}
