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

final class FiringSystem: ListIteratingSystem {
    private weak var torpedoCreator: TorpedoCreatorUseCase?
    private weak var engine: Engine?
    
    init(torpedoCreator: TorpedoCreatorUseCase) {
        super.init(nodeClass: FiringNode.self)
        self.torpedoCreator = torpedoCreator
        nodeUpdateFunction = updateNode
    }

    override public func addToEngine(engine: Engine) {
        super.addToEngine(engine: engine)
        self.engine = engine
    }
    
    override public func removeFromEngine(engine: Engine) {
        super.removeFromEngine(engine: engine)
        self.engine = nil
        torpedoCreator = nil
    }

    func updateNode(node: Node, time: TimeInterval) {
        guard let velocity = node[VelocityComponent.self],
              let position = node[PositionComponent.self],
              let gun = node[GunComponent.self],
              let _ = node[FireDownComponent.self]
        else { return }
        gun.timeSinceLastShot += time
        guard gun.timeSinceLastShot >= gun.minimumShotInterval else { return }
        gun.timeSinceLastShot = 0
        node.entity?.remove(componentClass: FireDownComponent.self)
        let pos = PositionComponent(x: position.x, y: position.y, z: .asteroids, rotationDegrees: position.rotationDegrees)
        torpedoCreator?.createTorpedo(gun, pos, velocity)
        gun.numTorpedoes -= 1
        if let appState = engine?.gameStateComponent {
            appState.numTorpedoesPlayerFired += 1
        }
    }
}
