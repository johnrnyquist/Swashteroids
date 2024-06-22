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

// TODO: This system could be split into two systems, one for finding a target and one for moving toward it.
class AlienSystem: System {
    var engine: Engine?
    var shipEntity: Entity?
    let randomness: Randomizing

    init(randomness: Randomizing = Randomness.initialize(with: 1)) {
        self.randomness = randomness
        super.init()
    }

    // MARK: - System overrides
    override func addToEngine(engine: Engine) {
        super.addToEngine(engine: engine)
        self.engine = engine
        shipEntity = engine.ship
    }

    // MARK: - AlienSystem
    var playerAlive: Bool {
        shipEntity != nil && shipEntity?[DeathThroesComponent.self] == nil
    }

    func updateAlienReactionTime(alienComponent: AlienComponent, time: TimeInterval) {
        alienComponent.timeSinceLastReaction += time
        if alienComponent.timeSinceLastReaction >= alienComponent.reactionTime {
            alienComponent.timeSinceLastReaction = 0
        }
    }

    func isTargetDead(_ entity: Entity?) -> Bool {
        guard let entity = entity else { return true }
        return engine?.findEntity(named: entity.name) == nil
    }

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
