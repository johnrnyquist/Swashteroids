//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import Swash
import SpriteKit

final class AlienFiringSystem: System {
    private var torpedoCreator: TorpedoCreatorUseCase?
    private weak var firingNodes: NodeList?
    private let gameRect: CGRect

    init(torpedoCreator: TorpedoCreatorUseCase, gameSize: CGSize) {
        self.torpedoCreator = torpedoCreator
        gameRect = CGRect(origin: .zero, size: gameSize)
    }

    override public func addToEngine(engine: Engine) {
        firingNodes = engine.getNodeList(nodeClassType: AlienFiringNode.self)
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
              let _ = node[AlienFireDownComponent.self]
        else { return }
        gun.timeSinceLastShot += time
        //
        guard gun.timeSinceLastShot >= gun.minimumShotInterval, gameRect.contains(position.position) else { return }
        //
        gun.timeSinceLastShot = 0
        var pos = PositionComponent(x: position.x, y: position.y, z: .asteroids, rotationDegrees: position.rotationDegrees)
        torpedoCreator?.createTorpedo(gun, pos, velocity)
        //
        guard let _ = node.entity?[AlienSoldierComponent.self] else { return }
        pos = PositionComponent(x: position.x,
                                y: position.y,
                                z: .asteroids,
                                rotationDegrees: position.rotationDegrees + 30.0)
        torpedoCreator?.createTorpedo(gun, pos, velocity)
        pos = PositionComponent(x: position.x,
                                y: position.y,
                                z: .asteroids,
                                rotationDegrees: position.rotationDegrees - 30.0)
        torpedoCreator?.createTorpedo(gun, pos, velocity)
    }
}
