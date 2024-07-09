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

final class MoveToTargetSystem: ListIteratingSystem {
    weak var playerNodes: NodeList!
    weak var engine: Engine!

    init() {
        super.init(nodeClass: MoveToTargetNode.self)
        nodeUpdateFunction = updateNode
    }

    override func addToEngine(engine: Engine) {
        super.addToEngine(engine: engine)
        self.engine = engine
        playerNodes = engine.getNodeList(nodeClassType: PlayerNode.self)
    }

    var playerDead: Bool {
        playerNodes?.head?.entity == nil || playerNodes?.head?.entity?.has(componentClass: DeathThroesComponent.self) == true
    }

    func updateNode(node: Node, time: TimeInterval) {
        guard let targetComponent = node[MoveToTargetComponent.self],
              let positionComponent = node[PositionComponent.self],
              let velocityComponent = node[VelocityComponent.self],
              let alienComponent = node[AlienComponent.self],
              let entity = node.entity
        else { return }
        if playerDead {
            positionComponent.rotationRadians = alienComponent.destinationEnd.x > 0 ? 0 : CGFloat.pi
            velocityComponent.linearVelocity = CGPoint(x: (alienComponent.destinationEnd
                                                                         .x > 0 ? velocityComponent.exitSpeed : -velocityComponent.exitSpeed),
                                                       y: 0)
            entity.remove(componentClass: GunComponent.self)
            entity.remove(componentClass: MoveToTargetComponent.self)
            entity.add(component: ExitScreenComponent())
            return
        }
        if let targetPoint = engine.findEntity(named: targetComponent.targetedEntityName)?[PositionComponent.self]?.point {
            moveTowardTarget(cast: alienComponent.cast,
                             position: positionComponent,
                             velocity: velocityComponent,
                             targetPoint: targetPoint)
        }
    }

    // Aliens move differently from the player. They can make sharp moves when rotating.
    func moveTowardTarget(cast: AlienCast, position: PositionComponent, velocity: VelocityComponent, targetPoint: CGPoint) {
        let deltaX = position.x - targetPoint.x
        let deltaY = position.y - targetPoint.y
        let angleInRadians = atan2(deltaY, deltaX)
        // Interpolate between the current rotation and the target rotation
        let interpolationFactor = CGFloat(cast.rotationSpeed) // Adjust this value to change the size of rotation
        let currentAngleInRadians = position.rotationRadians - CGFloat.pi
        let angleDifference = angleInRadians - currentAngleInRadians
        let angleDifferenceNormalized = atan2(sin(angleDifference), cos(angleDifference)) // Normalize to [-pi, pi]
        let newAngleInRadians = currentAngleInRadians + angleDifferenceNormalized * interpolationFactor
        //
//        velocity.linearVelocity = CGPoint(x: -cos(angleInRadians) * velocity.base, y: -sin(angleInRadians) * velocity.base)
//        position.rotationRadians = angleInRadians + CGFloat.pi
        velocity.linearVelocity = CGPoint(x: -cos(newAngleInRadians) * velocity.base, y: -sin(newAngleInRadians) * velocity.base)
        position.rotationRadians = newAngleInRadians + CGFloat.pi
    }
}
