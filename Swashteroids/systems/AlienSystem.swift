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
    var asteroidNodes: NodeList?
    var engine: Engine?

    override func addToEngine(engine: Engine) {
        self.engine = engine
        alienNodes = engine.getNodeList(nodeClassType: AlienNode.self)
        shipNodes = engine.getNodeList(nodeClassType: ShipNode.self)
        asteroidNodes = engine.getNodeList(nodeClassType: AsteroidCollisionNode.self)
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
           isTimeToReact {
            alienComponent.timeSinceLastReaction = 0
            pickTarget(alienComponent, position)
            targeting(position, velocity, alienComponent.targetEntity![PositionComponent.self]!.position)
        }
        //
        // Move it off screen if player is dead, this happens ONCE
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

    private func findClosestAsteroid(_ position: CGPoint) -> Entity? {
        var closestAsteroid: Entity?
        var smallestDistance = Double.greatestFiniteMagnitude
        var asteroidCollisionNode = asteroidNodes?.head
        while let currentAsteroidNode = asteroidCollisionNode {
            if let asteroidPosition = currentAsteroidNode.entity?[PositionComponent.self] {
                let distance = position.distance(from: asteroidPosition.position)
                if distance < smallestDistance {
                    smallestDistance = distance
                    closestAsteroid = currentAsteroidNode.entity
                }
            }
            asteroidCollisionNode = currentAsteroidNode.next
        }
        return closestAsteroid
    }

    private func pickTarget(_ component: AlienComponent, _ position: PositionComponent) {
//        guard component.targetEntity == nil else { return }
        let closestAsteroid = findClosestAsteroid(position.position)
        if let closestAsteroid,
           let ship = shipNodes?.head?.entity {
            let asteroidPosition = closestAsteroid[PositionComponent.self]!.position
            let shipPosition = ship[PositionComponent.self]!.position
            let asteroidDistance = position.position.distance(from: asteroidPosition)
            let shipDistance = position.position.distance(from: shipPosition)
            if asteroidDistance < shipDistance {
                component.targetEntity = closestAsteroid
            } else {
                component.targetEntity = ship
            }
        }
    }
}
