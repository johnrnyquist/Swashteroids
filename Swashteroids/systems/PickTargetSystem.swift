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

final class PickTargetSystem: ListIteratingSystem {
    weak var asteroidNodes: NodeList!
    weak var shipNodes: NodeList!
    weak var targetableNodes: NodeList!

    init() {
        super.init(nodeClass: PickTargetNode.self)
        nodeUpdateFunction = updateNode
    }

    override func addToEngine(engine: Engine) {
        super.addToEngine(engine: engine)
        asteroidNodes = engine.getNodeList(nodeClassType: AsteroidCollisionNode.self)
        shipNodes = engine.getNodeList(nodeClassType: ShipNode.self)
        targetableNodes = engine.getNodeList(nodeClassType: AlienWorkerTargetNode.self)
    }

    func updateNode(node: Node, time: TimeInterval) {
        guard let component = node[PickTargetComponent.self],
              let alienComponent = node[AlienComponent.self],
              let positionComponent = node[PositionComponent.self],
              let velocityComponent = node[VelocityComponent.self],
              let entity = node.entity
        else { return }
        entity.remove(componentClass: type(of: component))
        pickTarget(entity: entity, alienComponent: alienComponent, position: positionComponent, velocity: velocityComponent)
    }

    func pickTarget(entity: Entity, alienComponent: AlienComponent, position: PositionComponent, velocity: VelocityComponent) {
        switch alienComponent.cast {
        case .soldier:
            // is there a ship and an asteroid?
            if let shipEntity = shipNodes.head?.entity,
               !shipEntity.has(componentClass: DeathThroesComponent.self),
               let closestAsteroid = findClosestEntity(to: position.position, node: asteroidNodes?.head) {
                // is ship closer than asteroid?
                let distanceToAsteroid = position.position.distance(from: closestAsteroid[PositionComponent.self]!.position)
                if distanceToAsteroid < alienComponent.maxTargetableRange/1.5 {
                    updateMoveToTarget(entity: entity, targetedEntity: closestAsteroid)
                } else {
                    updateMoveToTarget(entity: entity, targetedEntity: shipEntity)
                }
            } else if let shipEntity = shipNodes.head?.entity,
                      !shipEntity.has(componentClass: DeathThroesComponent.self) {
                updateMoveToTarget(entity: entity, targetedEntity: shipEntity)
            } else {
                // No ship, exit screen
                position.rotationRadians = alienComponent.destinationEnd.x > 0 ? 0 : CGFloat.pi
                velocity.linearVelocity = CGPoint(x: (alienComponent.destinationEnd.x > 0 ? velocity.exit : -velocity.exit), y: 0)
                entity.remove(componentClass: GunComponent.self)
                entity.remove(componentClass: MoveToTargetComponent.self)
                entity.add(component: ExitScreenComponent())
            }
        case .worker:
            if let shipEntity = shipNodes.head?.entity,
               !shipEntity.has(componentClass: DeathThroesComponent.self),
               let targetedEntity = findClosestEntity(to: position.position, node: targetableNodes?.head) {
                //TODO: I should NOT have to remove the component as adding it should overwrite the previous, 
                // but it did not work without doing so. Oddly I do not have to do it for the soldier.
                updateMoveToTarget(entity: entity, targetedEntity: targetedEntity)
            } else {
                // Nothing to target, exit screen
                position.rotationRadians = alienComponent.destinationEnd.x > 0 ? 0 : CGFloat.pi
                velocity.linearVelocity = CGPoint(x: (alienComponent.destinationEnd.x > 0 ? velocity.exit : -velocity.exit), y: 0)
                entity.remove(componentClass: GunComponent.self)
                entity.remove(componentClass: MoveToTargetComponent.self)
                entity.add(component: ExitScreenComponent())
            }
        }
//        print("\n\(self) \(entity.name) is targeting \(entity.find(componentClass: MoveToTargetComponent.self)?.targetedEntity?.name)\n")
    }

    private func updateMoveToTarget(entity: Entity, targetedEntity: Entity) {
        if let move =  entity.find(componentClass: MoveToTargetComponent.self) {
            move.targetedEntityName = targetedEntity.name
        } else {
            entity.add(component: MoveToTargetComponent(target: targetedEntity.name))
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
        // Create a sequence of nodes starting from the given node
        let nodeSequence = sequence(first: node, next: { $0.next })
        // Extract entities and their positions from the sequence of nodes
        let entitiesWithPositions = nodeSequence.compactMap { node -> (entity: Entity, position: CGPoint)? in
            guard let entity = node.entity,
                  let positionComponent = entity[PositionComponent.self] else {
                return nil
            }
            return (entity: entity, position: positionComponent.position)
        }
        // Find and return the entity that is closest to the given position
        return findClosestEntity(to: position, in: entitiesWithPositions)
    }

    /// Find the entity closest to the given position.
    /// Called from findClosestEntity(to:node:) and findClosestObject(to:in:)
    /// - Parameters:
    ///   - position: The position to compare against.
    ///   - entitiesWithPositions: A list of entities and their positions as CGPoints in the form of an array of tuples.
    /// - Returns: The entity closest to the given position.
    func findClosestEntity(to position: CGPoint, in entitiesWithPositions: [(entity: Entity, position: CGPoint)]) -> Entity? {
        guard !entitiesWithPositions.isEmpty else { return nil }
        return entitiesWithPositions.min(by: { position.distance(from: $0.position) < position.distance(from: $1.position) })?
                                    .entity
    }
}


