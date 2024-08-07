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
    weak var playerNodes: NodeList!
    weak var targetableNodes: NodeList!
    weak var engine: Engine!

    init() {
        super.init(nodeClass: PickTargetNode.self)
        nodeUpdateFunction = updateNode
    }

    override func addToEngine(engine: Engine) {
        super.addToEngine(engine: engine)
        self.engine = engine
        asteroidNodes = engine.getNodeList(nodeClassType: AsteroidCollisionNode.self)
        playerNodes = engine.getNodeList(nodeClassType: PlayerNode.self)
        targetableNodes = engine.getNodeList(nodeClassType: AlienWorkerTargetNode.self)
    }

    func updateNode(node: Node, time: TimeInterval) {
        guard let entity = node.entity,
              !entity.has(componentClass: ExitScreenComponent.self) // Don't pick a target if the alien is exiting the screen
        else { return }
        entity.remove(componentClass: PickTargetComponent.self)
        pickTarget(entity: entity)
    }

    func pickTarget(entity: Entity) {
        guard let alienComponent = entity[AlienComponent.self],
              let position = entity[PositionComponent.self],
              let velocity = entity[VelocityComponent.self]
        else { return }
        switch alienComponent.cast {
            case .soldier:
                handleSoldierTargeting(entity: entity, position: position, velocity: velocity, alienComponent: alienComponent)
            case .worker:
                handleWorkerTargeting(entity: entity, position: position, alienComponent: alienComponent)
        }
    }

    private func handleSoldierTargeting(entity: Entity, position: PositionComponent, velocity: VelocityComponent, alienComponent: AlienComponent) {
        guard let player = playerNodes.head?.entity,
              !player.has(componentClass: DeathThroesComponent.self) else {
            exitScreen(position: position, velocity: velocity, alienComponent: alienComponent, entity: entity)
            return
        }
        if let closestAsteroid = findClosestEntity(to: position.point, node: asteroidNodes?.head) {
            let distanceToAsteroid = position.point.distance(from: closestAsteroid[PositionComponent.self]!.point)
            if distanceToAsteroid < alienComponent.maxTargetableRange / 1.5 {
                updateMoveToTarget(entity: entity, targetedEntity: closestAsteroid)
                return
            }
        }
        updateMoveToTarget(entity: entity, targetedEntity: player)
    }

    private func handleWorkerTargeting(entity: Entity, position: PositionComponent, alienComponent: AlienComponent) {
        guard let player = playerNodes.head?.entity,
              !player.has(componentClass: DeathThroesComponent.self) else {
            exitScreen(position: position,
                       velocity: entity[VelocityComponent.self]!,
                       alienComponent: alienComponent,
                       entity: entity)
            return
        }
        let excludedEntityNames = getExcludedEntityNames(currentTarget: entity.find(componentClass: MoveToTargetComponent.self)?
                                                                              .targetedEntityName)
        if let targetedEntity = findClosestEntity(to: position.point,
                                                  node: targetableNodes?.head,
                                                  excludingEntities: excludedEntityNames) {
            updateMoveToTarget(entity: entity, targetedEntity: targetedEntity)
        } else {
            updateMoveToTarget(entity: entity, targetedEntity: player)
        }
    }

    private func getExcludedEntityNames(currentTarget: String?) -> [String] {
        guard let currentTarget = currentTarget else { return [] }
        return engine.findComponents(componentClass: MoveToTargetComponent.self)
                     .map(\.targetedEntityName)
                     .filter { $0 != currentTarget }
    }

    private func exitScreen(position: PositionComponent, velocity: VelocityComponent, alienComponent: AlienComponent, entity: Entity) {
        position.rotationRadians = alienComponent.destinationEnd.x > 0 ? 0 : CGFloat.pi
        velocity.angularVelocity = 0
        velocity.linearVelocity = CGPoint(x: (alienComponent.destinationEnd.x > 0 ? velocity.exitSpeed : -velocity.exitSpeed),
                                          y: 0)
        entity.remove(componentClass: GunComponent.self)
        entity.remove(componentClass: MoveToTargetComponent.self)
        entity.add(component: ExitScreenComponent())
    }

    private func updateMoveToTarget(entity: Entity, targetedEntity: Entity) {
        if let moveToTargetComponent = entity.find(componentClass: MoveToTargetComponent.self) {
            moveToTargetComponent.targetedEntityName = targetedEntity.name
        } else {
            entity.add(component: MoveToTargetComponent(hunterName: entity.name, targetName: targetedEntity.name))
        }
    }

    func findClosestEntity(to position: CGPoint, node: Node?, excludingEntities excludedEntityNames: [String] = []) -> Entity? {
        guard let node = node else { return nil }
        let nodeSequence = sequence(first: node, next: { $0.next })
        let entitiesWithPositions = nodeSequence.compactMap { node -> (entity: Entity, position: CGPoint)? in
            guard let entity = node.entity,
                  let positionComponent = entity[PositionComponent.self],
                  !excludedEntityNames.contains(entity.name) else {
                return nil
            }
            return (entity: entity, position: positionComponent.point)
        }
        return findClosestEntity(to: position, in: entitiesWithPositions)
    }

    func findClosestEntity(to position: CGPoint, in entitiesWithPositions: [(entity: Entity, position: CGPoint)]) -> Entity? {
        guard !entitiesWithPositions.isEmpty else { return nil }
        return entitiesWithPositions.min(by: { position.distance(from: $0.position) < position.distance(from: $1.position) })?
                                    .entity
    }
}
