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

class DistanceComponent: Component {
    let distance: CGFloat

    init(distance: CGFloat) {
        self.distance = distance
        super.init()
    }
}

// TODO: This system could be split into two systems, one for finding a target and one for moving toward it.
class AlienSystem: System {
    func findClosestObject(to point: CGPoint, in entities: [Entity]) -> Entity {
        // I could change map to a filter but it really is an error if this was called with an entity that did not have a PositionComponent
        findClosestEntity(to: point, in: entities.map { entity in
            if let position = entity[PositionComponent.self] {
                return (entity, position.position)
            } else {
                fatalError("Entities must have a position component to find the closest object.")
            }
        })
    }

    func hasReachedDestination(_ x: Double, _ endDestination: CGPoint) -> Bool {
        if endDestination.x > 0 {
            return x >= endDestination.x
        } else {
            return x <= endDestination.x
        }
    }

    /// Find the entity closest to the given position.
    /// Called from pickTarget(alienComponent:position:)
    /// - Parameters:
    ///   - position: The position to compare against.
    ///   - node: The node to start the search from.
    /// - Returns: The entity closest to the given position.
    func findClosestEntity(to position: CGPoint, node: Node?) -> Entity? {
        guard let node = node else { return nil }
        let entitiesWithPositions
            = sequence(first: node, next: { $0.next })
                .compactMap { $0.entity }
                .compactMap { entity in
                    entity[PositionComponent.self]
                            .map { (entity, $0.position) }
                }
        return findClosestEntity(to: position, in: entitiesWithPositions)
    }

    /// Find the entity closest to the given position.
    /// Called from findClosestEntity(to:node:) and findClosestObject(to:in:)
    /// - Note: This function adds a `DistanceComponent` to the closest entity.
    /// - Parameters:
    ///   - position: The position to compare against.
    ///   - entitiesWithPositions: A list of entities and their positions as CGPoints in the form of an array of tuples.
    /// - Returns: The entity closest to the given position.
    func findClosestEntity(to position: CGPoint, in entitiesWithPositions: [(Entity, CGPoint)]) -> Entity {
        var closestEntity: Entity = entitiesWithPositions[0].0
        var smallestDistance: CGFloat = .greatestFiniteMagnitude
        for (entity, entityPosition) in entitiesWithPositions {
            let distance = position.distance(from: entityPosition)
            if distance < smallestDistance {
                smallestDistance = distance
                closestEntity = entity
                closestEntity.add(component: DistanceComponent(distance: distance))
            }
        }
        return closestEntity
    }

    // Aliens move differently from the player. They can make sharp moves when rotating.
    func moveTowardTarget(_ position: PositionComponent, _ velocity: VelocityComponent, _ target: CGPoint) {
        let deltaX = position.x - target.x
        let deltaY = position.y - target.y
        let angleInRadians = atan2(deltaY, deltaX)
        // Interpolate between the current rotation and the target rotation
//        let interpolationFactor = CGFloat(0.8) // Adjust this value to change the size of rotation
//        let currentAngleInRadians = position.rotationRadians - CGFloat.pi
//        let angleDifference = angleInRadians - currentAngleInRadians
//        let angleDifferenceNormalized = atan2(sin(angleDifference), cos(angleDifference)) // Normalize to [-pi, pi]
//        let newAngleInRadians = currentAngleInRadians + angleDifferenceNormalized * interpolationFactor
        //
        velocity.linearVelocity = CGPoint(x: -cos(angleInRadians) * velocity.base, y: -sin(angleInRadians) * velocity.base)
        position.rotationRadians = angleInRadians + CGFloat.pi
//        velocity.linearVelocity = CGPoint(x: -cos(newAngleInRadians) * velocity.base, y: -sin(newAngleInRadians) * velocity.base)
//        position.rotationRadians = newAngleInRadians + CGFloat.pi
    }
}

class AlienWorkerSystem: AlienSystem {
    var engine: Engine?
    var alienNodes: NodeList?
    var shipEntity: Entity?
    var targetableNodes: NodeList?
    let randomness: Randomizing

    init(randomness: Randomizing = Randomness.shared) {
        self.randomness = randomness
        super.init()
    }

    // MARK: - System overrides
    override func addToEngine(engine: Engine) {
        self.engine = engine
        shipEntity = engine.ship
        alienNodes = engine.getNodeList(nodeClassType: AlienWorkerNode.self)
        targetableNodes = engine.getNodeList(nodeClassType: AlienWorkerTargetNode.self)
    }

    override func update(time: TimeInterval) {
        var alienNode = alienNodes?.head
        while let currentNode = alienNode {
            updateNode(node: currentNode, time: time)
            alienNode = currentNode.next
        }
    }

    // MARK: - AlienWorkerSystem
    var playerDead: Bool {
        let shipEntity = engine?.ship
        let playerAlive = shipEntity != nil && shipEntity?[DeathThroesComponent.self] == nil
        return !playerAlive
    }

    func updateNode(node alienNode: Node, time: TimeInterval) {
        guard let alienPosition = alienNode[PositionComponent.self],
              let velocity = alienNode[VelocityComponent.self],
              let alienComponent = alienNode[AlienComponent.self],
              alienNode.entity?[DeathThroesComponent.self] == nil,
              let alienEntity = alienNode.entity
        else { return }
        updateAlienReactionTime(alienComponent: alienComponent, time: time)
        if playerDead {
            handlePlayerDeath(alienEntity: alienEntity,
                              alienComponent: alienComponent,
                              alienPosition: alienPosition,
                              velocity: velocity)
        } else if alienComponent.reactionTime == 0 {
            handleTargeting(alienComponent: alienComponent, alienPosition: alienPosition, velocity: velocity)
        }
    }

    func updateAlienReactionTime(alienComponent: AlienComponent, time: TimeInterval) {
        alienComponent.timeSinceLastReaction += time
        if alienComponent.timeSinceLastReaction >= alienComponent.reactionTime {
            alienComponent.timeSinceLastReaction = 0
        }
    }

    func handlePlayerDeath(alienEntity: Entity, alienComponent: AlienComponent, alienPosition: PositionComponent, velocity: VelocityComponent) {
        // HACK: Using the presence of a GunComponent to determine if this is the first time detecting the player has died is not ideal. This is a temporary solution.
        if let _ = alienEntity[GunComponent.self] {
            onFirstDetectionOfPlayerDeath(alienEntity: alienEntity,
                                          alienComponent: alienComponent,
                                          alienPosition: alienPosition,
                                          velocity: velocity)
        }
        removeIfOffscreen(alienEntity: alienEntity,
                          alienComponent: alienComponent,
                          alienPosition: alienPosition)
    }

    func handleTargeting(alienComponent: AlienComponent, alienPosition: PositionComponent, velocity: VelocityComponent) {
        alienComponent.targetedEntity = findClosestEntity(to: alienPosition.position, node: targetableNodes?.head)
        if let target = alienComponent.targetedEntity,
           let targetPosition = target[PositionComponent.self] {
            moveTowardTarget(alienPosition, velocity, targetPosition.position)
        }
    }

    func onFirstDetectionOfPlayerDeath(alienEntity: Entity, alienComponent: AlienComponent, alienPosition: PositionComponent, velocity: VelocityComponent) {
        // HACK: Using the presence of a GunComponent to determine if this is the first time detecting the player has died is not ideal. This is a temporary solution.
        guard alienEntity[GunComponent.self] != nil
        else { return }
        alienEntity.remove(componentClass: GunComponent.self)
        alienPosition.rotationRadians = alienComponent.destinationEnd.x > 0 ? 0 : CGFloat.pi
        velocity.linearVelocity = CGPoint(x: (alienComponent.destinationEnd.x > 0 ? velocity.exit : -velocity.exit), y: 0)
    }

    func removeIfOffscreen(alienEntity: Entity, alienComponent: AlienComponent, alienPosition: PositionComponent) {
        if hasReachedDestination(alienPosition.x, alienComponent.destinationEnd) {
            engine?.remove(entity: alienEntity)
        }
    }
}

class AlienSoldierSystem: AlienSystem {
    var engine: Engine?
    var alienNodes: NodeList?
    var shipNodes: NodeList?
    var asteroidNodes: NodeList?

    override func addToEngine(engine: Engine) {
        self.engine = engine
        alienNodes = engine.getNodeList(nodeClassType: AlienSoldierNode.self)
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

    func updateNode(node alienNode: Node, time: TimeInterval) {
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
        // Does the alien have a target? If so, is the target still alive?
        if let _ = alienComponent.targetedEntity,
           let name = alienComponent.targetedEntity?.name,
           engine?.findEntity(named: name) == nil {
            alienComponent.targetedEntity = nil
        }
        //
        // Target the ship if it's alive and it's time to react
        if playerAlive,
           isTimeToReact {
            alienComponent.timeSinceLastReaction = 0
            pickTarget(alienComponent: alienComponent, position: alienPosition)
            moveTowardTarget(alienPosition, velocity, alienComponent.targetedEntity![PositionComponent.self]!.position)
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
        let ship = shipNodes?.head?.entity
        if let ship,
           let _ = asteroidNodes?.head?.entity,
           let closestAsteroid = findClosestEntity(to: position.position, node: asteroidNodes?.head) {
            // is ship closer than asteroid?
            let distanceToAsteroid = position.position.distance(from: closestAsteroid[PositionComponent.self]!.position)
            if distanceToAsteroid < alienComponent.maxTargetableRange / 2.0 {
                alienComponent.targetedEntity = closestAsteroid
            } else {
                alienComponent.targetedEntity = ship
            }
        } else {
            alienComponent.targetedEntity = ship // okay if ship is nil
        } 
    }
}
