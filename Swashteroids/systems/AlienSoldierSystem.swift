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

class AlienSoldierSystem: AlienSystem {
    var alienSoldierNodes: NodeList?
    var asteroidNodes: NodeList?
    // MARK: - System overrides
    override func update(time: TimeInterval) {
        var alienNode = alienSoldierNodes?.head
        while let currentNode = alienNode {
            updateNode(node: currentNode, time: time)
            alienNode = currentNode.next
        }
    }

    // MARK: - AlienSystem overrides
    override func addToEngine(engine: Engine) {
        self.engine = engine
        alienSoldierNodes = engine.getNodeList(nodeClassType: AlienSoldierNode.self)
        asteroidNodes = engine.getNodeList(nodeClassType: AsteroidCollisionNode.self)
    }

    // MARK: - AlienSoldierSystem methods
    func updateNode(node alienNode: Node, time: TimeInterval) {
        guard let alienPosition = alienNode[PositionComponent.self],
              let velocity = alienNode[VelocityComponent.self],
              let alienComponent = alienNode[AlienComponent.self],
              let alienEntity = alienNode.entity,
              alienEntity[DeathThroesComponent.self] == nil
        else { return }
        updateAlienReactionTime(alienComponent: alienComponent, time: time)
        let isTimeToReact = alienComponent.timeSinceLastReaction == 0
        //
        // Has the alien's target been destroyed, if so, nil it out.
        // Since it is a weak reference, this may be unnecessary.
        if isTargetDead(alienComponent.targetedEntity) {
            alienComponent.targetedEntity = nil
        }
        //
        // Target the ship if it's alive and it's time to react
        if playerAlive,
           isTimeToReact {
            alienComponent.timeSinceLastReaction = 0
            pickTarget(alienComponent: alienComponent, position: alienPosition)
            moveTowardTarget(alienPosition, velocity, alienComponent.targetedEntity![PositionComponent.self]!.position)
            return
        }
        //
        // Move it off screen if player is dead, this happens ONCE
        if !playerAlive,
           alienEntity[GunComponent.self] != nil {
            alienEntity.remove(componentClass: GunComponent.self)
            alienPosition.rotationRadians = alienComponent.destinationEnd.x > 0 ? 0 : CGFloat.pi
            velocity.linearVelocity = CGPoint(x: (alienComponent.destinationEnd.x > 0 ? velocity.exit : -velocity.exit),
                                              y: 0)
            return
        }
        //
        // Remove if player is dead and it's off screen
        if !playerAlive,
           hasReachedDestination(alienPosition.x, alienComponent.destinationEnd) {
            engine?.remove(entity: alienEntity)
            return
        }
    }

    func pickTarget(alienComponent: AlienComponent, position: PositionComponent) {
        // is there a ship and an asteroid?
        if let shipEntity,
           let _ = asteroidNodes?.head?.entity,
           let closestAsteroid = findClosestEntity(to: position.position, node: asteroidNodes?.head) {
            // is ship closer than asteroid?
            let distanceToAsteroid = position.position.distance(from: closestAsteroid[PositionComponent.self]!.position)
            if distanceToAsteroid < alienComponent.maxTargetableRange / 2.0 {
                alienComponent.targetedEntity = closestAsteroid
            } else {
                alienComponent.targetedEntity = shipEntity
            }
        } else {
            alienComponent.targetedEntity = shipEntity // okay if ship is nil
        }
    }
}
