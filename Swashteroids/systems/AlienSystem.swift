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
                let targetAngleInRadians = atan2(deltaY, deltaX)

                // Interpolate between the current rotation and the target rotation
                let interpolationFactor = CGFloat(0.1) // Adjust this value to change the speed of rotation
                let currentAngleInRadians = alienPosition.rotationRadians - CGFloat.pi
                let angleDifference = targetAngleInRadians - currentAngleInRadians
                let angleDifferenceNormalized = atan2(sin(angleDifference), cos(angleDifference)) // Normalize to [-pi, pi]
                let newAngleInRadians = currentAngleInRadians + angleDifferenceNormalized * interpolationFactor

                alienVelocity.linearVelocity = CGPoint(x: -cos(newAngleInRadians) * 60, y: -sin(newAngleInRadians) * 60)
                alienPosition.rotationRadians = newAngleInRadians + CGFloat.pi
            }
        }
    }
}
