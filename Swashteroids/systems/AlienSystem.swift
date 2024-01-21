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
    func pickTarget(alienComponent: AlienComponent, position: PositionComponent) {
        preconditionFailure("\(#function) must be overridden in \(self)")
    }

    func moveTowardTarget(_ position: PositionComponent, _ velocity: VelocityComponent, _ target: CGPoint) {
        preconditionFailure("\(#function) must be overridden in \(self)")
    }

    func findClosestObject(to point: CGPoint, in entities: [Entity]) -> Entity {
        return findClosestEntity(to: point, in: entities.map { ($0, $0[PositionComponent.self]!.position) })
    }

    func hasReachedDestination(_ x: Double, _ endDestination: CGPoint) -> Bool {
        if endDestination.x > 0 {
            return x >= endDestination.x
        } else {
            return x <= endDestination.x
        }
    }

    func findClosestEntity(to position: CGPoint, node: Node?) -> Entity? {
        guard let node = node else { return nil }
        let entitiesWithPositions = sequence(first: node, next: { $0.next })
                .compactMap { $0.entity }
                .compactMap { entity in entity[PositionComponent.self].map { (entity, $0.position) } }
        return findClosestEntity(to: position, in: entitiesWithPositions)
    }

    private func findClosestEntity(to position: CGPoint, in entitiesWithPositions: [(Entity, CGPoint)]) -> Entity {
        var closestEntity: Entity = entitiesWithPositions[0].0
        var smallestDistance: CGFloat = .greatestFiniteMagnitude
        for (entity, entityPosition) in entitiesWithPositions {
            let distance = position.distance(from: entityPosition)
            if distance < smallestDistance {
                smallestDistance = distance
                closestEntity = entity
            }
        }
        return closestEntity
    }
}

class AlienWorkerSystem: AlienSystem {
    var engine: Engine?
    var alienNodes: NodeList?
    var shipNodes: NodeList?
    var asteroidNodes: NodeList?
    var treasureNodes: NodeList?

    override func addToEngine(engine: Engine) {
        self.engine = engine
        alienNodes = engine.getNodeList(nodeClassType: AlienWorkerNode.self)
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
        if let _ = alienComponent.targetingEntity,
           let name = alienComponent.targetingEntity?.name,
           engine?.findEntity(named: name) == nil {
            alienComponent.targetingEntity = nil
        }
        //
        // Target the ship if it's alive and it's time to react
        if playerAlive,
           isTimeToReact {
            alienComponent.timeSinceLastReaction = 0
            pickTarget(alienComponent: alienComponent, position: alienPosition)
            moveTowardTarget(alienPosition, velocity, alienComponent.targetingEntity![PositionComponent.self]!.position)
        }
        //
        // Move it off screen if player is dead, this happens ONCE
        if !playerAlive, alienEntity[GunComponent.self] != nil {
            alienEntity.remove(componentClass: GunComponent.self)
            alienPosition.rotationRadians = alienComponent.endDestination.x > 0 ? 0 : CGFloat.pi
            velocity.linearVelocity = CGPoint(x: (alienComponent.endDestination.x > 0 ? velocity.exit : -velocity.exit),
                                              y: 0)
            return
        }
        //
        // Remove if player is dead and it's off screen
        if !playerAlive,
           hasReachedDestination(alienPosition.x, alienComponent.endDestination) {
            engine?.remove(entity: alienEntity)
            return
        }
    }

    override func pickTarget(alienComponent: AlienComponent, position: PositionComponent) {
        guard alienComponent.targetingEntity == nil else { return }
        let ship = shipNodes?.head?.entity
        let closestAsteroid = findClosestEntity(to: position.position, node: asteroidNodes?.head)
        let closestTreasure = findClosestEntity(to: position.position, node: treasureNodes?.head)
        let entities = [closestAsteroid, closestTreasure].compactMap { $0 }
        if entities.count > 0 {
            alienComponent.targetingEntity = entities.randomElement()
        }
    }

    override func moveTowardTarget(_ position: PositionComponent, _ velocity: VelocityComponent, _ target: CGPoint) {
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

class AlienSoldierSystem: AlienSystem {
    var engine: Engine?
    var alienNodes: NodeList?
    var shipNodes: NodeList?
    var asteroidNodes: NodeList?
    var treasureNodes: NodeList?

    override func addToEngine(engine: Engine) {
        self.engine = engine
        alienNodes = engine.getNodeList(nodeClassType: AlienSoldierNode.self)
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
        if let _ = alienComponent.targetingEntity,
           let name = alienComponent.targetingEntity?.name,
           engine?.findEntity(named: name) == nil {
            alienComponent.targetingEntity = nil
        }
        //
        // Target the ship if it's alive and it's time to react
        if playerAlive,
           isTimeToReact {
            alienComponent.timeSinceLastReaction = 0
            pickTarget(alienComponent: alienComponent, position: alienPosition)
            moveTowardTarget(alienPosition, velocity, alienComponent.targetingEntity![PositionComponent.self]!.position)
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
           hasReachedDestination(alienPosition.x, alienComponent.endDestination) {
            engine?.remove(entity: alienEntity)
            return
        }
    }

    override func pickTarget(alienComponent: AlienComponent, position: PositionComponent) {
        guard alienComponent.targetingEntity == nil else { return }
        let ship = shipNodes?.head?.entity
        let closestAsteroid = findClosestEntity(to: position.position, node: asteroidNodes?.head)
        let closestTreasure = findClosestEntity(to: position.position, node: treasureNodes?.head)
//        let entities = [ship, ship, ship, ship, closestAsteroid, closestTreasure].compactMap { $0 }
//        alienComponent.targetingEntity = findClosestObject(to: position.position, in: entities)
        alienComponent.targetingEntity = ship
    }

    override func moveTowardTarget(_ position: PositionComponent, _ velocity: VelocityComponent, _ target: CGPoint) {
        let deltaX = position.x - target.x
        let deltaY = position.y - target.y
        let angleInRadians = atan2(deltaY, deltaX)
        velocity.linearVelocity = CGPoint(x: -cos(angleInRadians) * velocity.base, y: -sin(angleInRadians) * velocity.base)
        position.rotationRadians = angleInRadians + CGFloat.pi
    }
}
