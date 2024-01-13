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
    var engine: Engine?
    var alienNodes: NodeList?
    var shipNodes: NodeList?
    var asteroidNodes: NodeList?
    var treasureNodes: NodeList?

    override func addToEngine(engine: Engine) {
        self.engine = engine
        alienNodes = engine.getNodeList(nodeClassType: AlienNode.self)
        shipNodes = engine.getNodeList(nodeClassType: ShipNode.self)
        asteroidNodes = engine.getNodeList(nodeClassType: AsteroidCollisionNode.self)
        treasureNodes = engine.getNodeList(nodeClassType: TreasureCollisionNode.self)
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
              let velocity = alienNode[VelocityComponent.self],
              let alienComponent = alienNode[AlienComponent.self],
              alienNode.entity?[DeathThroesComponent.self] == nil,
              let alienEntity = alienNode.entity
        else { return }
        alienComponent.timeSinceLastReaction += time
        let isTimeToReact = alienComponent.timeSinceLastReaction >= alienComponent.reactionTime
        let shipEntity = shipNodes?.head?.entity
        let playerAlive = shipEntity != nil && shipEntity?[DeathThroesComponent.self] == nil
        //
        // Target the ship if it's alive and it's time to react
        if playerAlive,
           isTimeToReact {
            alienComponent.timeSinceLastReaction = 0
            pickTarget(alienComponent: alienComponent, position: alienPosition)
            targeting(alienPosition, velocity, alienComponent.targetingEntity![PositionComponent.self]!.position)
        }
        //
        // Move it off screen if player is dead, this happens ONCE
        if !playerAlive,
           alienEntity[GunComponent.self] != nil {
            alienEntity.remove(componentClass: GunComponent.self)
            alienPosition.rotationRadians = alienComponent.endDestination.x > 0 ? 0 : CGFloat.pi
            velocity.linearVelocity = CGPoint(x: (alienComponent.endDestination.x > 0 ? velocity.exit : -velocity.exit),
                                              y: 0)
            return
        }
        //
        // Remove if player is dead and it's off screen
        if !playerAlive,
           atEndDestination(alienPosition.x, alienComponent.endDestination) {
            engine?.remove(entity: alienEntity)
            return
        }
    }

    func findClosestObject(to point: CGPoint, in entities: [Entity]) -> Entity {
        var closestObject: Entity = entities[0]
        var smallestDistance: CGFloat = .greatestFiniteMagnitude
        for entity in entities {
            let distance = entity[PositionComponent.self]!.position.distance(from: entity[PositionComponent.self]!.position)
            if distance < smallestDistance {
                smallestDistance = distance
                closestObject = entity
            }
        }
        return closestObject
    }

    func pickTarget(alienComponent: AlienComponent, position: PositionComponent) {
        let ship = shipNodes?.head?.entity
        let closestAsteroid = findClosestEntity(to: position.position, node: asteroidNodes?.head)
        let closestTreasure = findClosestEntity(to: position.position, node: treasureNodes?.head)
        let entities = [ship, closestAsteroid, closestTreasure].compactMap { $0 }
        alienComponent.targetingEntity = findClosestObject(to: position.position, in: entities)
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

    func findClosestEntity(to position: CGPoint, node: Node?) -> Entity? {
        guard let _ = node else { return nil }
        var closestEntity: Entity?
        var smallestDistance = Double.greatestFiniteMagnitude
        var collidableNode = node
        while let currentNode = collidableNode {
            if let nodePosition = currentNode.entity?[PositionComponent.self] {
                let distance = position.distance(from: nodePosition.position)
                if distance < smallestDistance {
                    smallestDistance = distance
                    closestEntity = currentNode.entity
                }
            }
            collidableNode = currentNode.next
        }
        return closestEntity
    }
}
