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
import Foundation
import UIKit

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

    func targeting(_ position: PositionComponent, _ velocity: VelocityComponent, _ target: CGPoint) {
        let deltaX = position.x - target.x
        let deltaY = position.y - target.y
        let angleInRadians = atan2(deltaY, deltaX)
        velocity.linearVelocity = CGPoint(x: -cos(angleInRadians) * velocity.base, y: -sin(angleInRadians) * velocity.base)
        position.rotationRadians = angleInRadians + CGFloat.pi
    }

    func atEndDestination(_ x: Double, _ endDestination: CGPoint) -> Bool {
        if endDestination.x > 0 {
            return x >= endDestination.x
        } else {
            return x <= endDestination.x
        }
    }

    private func updateNode(node alienNode: Node, time: TimeInterval) {
        guard let position = alienNode[PositionComponent.self],
              let velocity = alienNode[VelocityComponent.self],
              let alienComponent = alienNode[AlienComponent.self],
              alienNode.entity?[DeathThroesComponent.self] == nil,
              let alienEntity = alienNode.entity
        else { return }
        // update reaction time
        alienComponent.timeSinceLastReaction += time
        // update position
        let shipEntity = shipNodes?.head?.entity
        let playerAlive = shipEntity != nil && shipEntity?[DeathThroesComponent.self] == nil
        let isTimeToReact = alienComponent.timeSinceLastReaction >= alienComponent.reactionTime
        //
        // Target the ship if it's alive and it's time to react
        if playerAlive,
           isTimeToReact,
           let shipPosition = shipEntity?[PositionComponent.self]?.position {
            alienComponent.timeSinceLastReaction = 0
            targeting(position, velocity, shipPosition)
        }
        //
        // Move it off screen if player is dead, this happens once
        if !playerAlive,
           alienEntity[GunComponent.self] != nil {
            alienEntity.remove(componentClass: GunComponent.self)
            position.rotationRadians = alienComponent.endDestination.x > 0 ? 0 : CGFloat.pi
            velocity.linearVelocity = CGPoint(x: (alienComponent.endDestination.x > 0 ? velocity.exit : -velocity.exit),
                                              y: 0)
            return
        }
        //
        // Remove if player is dead and it's off screen
        if !playerAlive,
           atEndDestination(position.x, alienComponent.endDestination) {
            engine?.remove(entity: alienEntity)
            return
        }
    }
}
