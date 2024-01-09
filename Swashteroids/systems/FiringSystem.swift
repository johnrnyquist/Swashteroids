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

class AlienNode: Node {
    required init() {
        super.init()
        components = [
            AlienComponent.name: nil_component,
            PositionComponent.name: nil_component,
            VelocityComponent.name: nil_component,
        ]
    }
}

class AlienSystem: System {
    var alienNodes: NodeList?
    var shipNodes: NodeList?
    var engine: Engine?

    override func addToEngine(engine: Engine) {
        self.engine = engine
        alienNodes = engine.getNodeList(nodeClassType: AlienNode.self)
        shipNodes = engine.getNodeList(nodeClassType: ShipNode.self)
    }

    override func update(time: TimeInterval) {
        var alienNode = alienNodes?.head
        while let currentNode = alienNode {
            updateNode(node: currentNode, time: time)
            alienNode = currentNode.next
        }
    }

    private func updateNode(node alienNode: Node, time: TimeInterval) {
        guard let alienPosition = alienNode[PositionComponent.self],
              let alienVelocity = alienNode[VelocityComponent.self],
              let alienComponent = alienNode[AlienComponent.self],
              alienNode.entity?[DeathThroesComponent.self] == nil
        else { return }
        
        alienComponent.timeSinceLastReaction += time
        
        if alienPosition.x > UIScreen.main.bounds.size.width, //HACK
           let entity = alienNode.entity {
            engine?.remove(entity: entity)
            return
        }
        
        let playerAlive = shipNodes?.head?.entity != nil && shipNodes?.head?.entity?[DeathThroesComponent.self] == nil
        
        if !playerAlive, alienNode.entity?[GunComponent.self] != nil {
            alienNode.entity?.remove(componentClass: GunComponent.self)
            alienPosition.rotationRadians = 0
            alienVelocity.linearVelocity = CGPoint(x: 100, y: 0)
            return
        }
        
        if playerAlive, 
           alienComponent.timeSinceLastReaction >= alienComponent.reactionTime {
            alienComponent.timeSinceLastReaction = 0
            if let shipPosition = shipNodes?.head?[PositionComponent.self] {
                let deltaX = alienPosition.x - shipPosition.x
                let deltaY = alienPosition.y - shipPosition.y
                let angleInRadians = atan2(deltaY, deltaX)
                alienVelocity.linearVelocity = CGPoint(x: -cos(angleInRadians) * 60, y: -sin(angleInRadians) * 60)
                alienPosition.rotationRadians = angleInRadians + CGFloat.pi
            }
        }
    }
}
