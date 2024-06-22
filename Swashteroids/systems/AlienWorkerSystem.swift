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

class AlienWorkerSystem: AlienSystem {
    var alienWorkerNodes: NodeList?
    var targetableNodes: NodeList?
    // MARK: - System overrides
    override func addToEngine(engine: Engine) {
        super.addToEngine(engine: engine)
        alienWorkerNodes = engine.getNodeList(nodeClassType: AlienWorkerNode.self)
        targetableNodes = engine.getNodeList(nodeClassType: AlienWorkerTargetNode.self)
    }

    override func update(time: TimeInterval) {
        var alienNode = alienWorkerNodes?.head
        while let currentNode = alienNode {
            updateNode(node: currentNode, time: time)
            alienNode = currentNode.next
        }
    }

    // MARK: - AlienWorkerSystem
    func updateNode(node alienNode: Node, time: TimeInterval) {
        guard let alienPosition = alienNode[PositionComponent.self],
              let velocity = alienNode[VelocityComponent.self],
              let alienComponent = alienNode[AlienComponent.self],
              alienNode.entity?[DeathThroesComponent.self] == nil,
              let alienEntity = alienNode.entity
        else { return }
        updateAlienReactionTime(alienComponent: alienComponent, time: time)
        let isTimeToReact = alienComponent.timeSinceLastReaction == 0
        if playerDead {
            handlePlayerDeath(alienEntity: alienEntity,
                              alienComponent: alienComponent,
                              alienPosition: alienPosition,
                              velocity: velocity)
        } else if isTimeToReact {
            handleTargeting(alienComponent: alienComponent, alienPosition: alienPosition, velocity: velocity)
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

