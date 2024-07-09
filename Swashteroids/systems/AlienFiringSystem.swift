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
import SpriteKit

final class AlienFiringSystem: ListIteratingSystem {
    private let gameRect: CGRect
    private weak var torpedoCreator: TorpedoCreatorUseCase?
    private weak var engine: Engine!

    init(torpedoCreator: TorpedoCreatorUseCase, gameSize: CGSize, scaleManager: ScaleManaging = ScaleManager.shared) {
        gameRect = CGRect(origin: .zero, size: gameSize)
        self.torpedoCreator = torpedoCreator
        super.init(nodeClass: AlienFiringNode.self)
        nodeUpdateFunction = updateNode
    }

    override public func addToEngine(engine: Engine) {
        super.addToEngine(engine: engine)
        self.engine = engine
    }
    
    func updateNode(node: Node, time: TimeInterval) {
        guard let gun = node[GunComponent.self] else { return }
        gun.timeSinceLastShot += time
        //
        guard let velocity = node[VelocityComponent.self],
              let position = node[PositionComponent.self],
              let _ = node[AlienFiringComponent.self],
              let alien = node[AlienComponent.self],
              let targetComponent = node[MoveToTargetComponent.self],
              let targetedEntity = engine.findEntity(named: targetComponent.targetedEntityName),
              targetedEntity.has(componentClass: DeathThroesComponent.self) == false
        else { return }
        //
        guard gun.timeSinceLastShot >= gun.minimumShotInterval, 
              gameRect.contains(position.point),
              targetWithinRange(targetedEntity, alien, position)
        else { return }
        //
        gun.timeSinceLastShot = 0
        createTorpedo(gun: gun, position: position, velocity: velocity, rotationOffset: 0)
        // At the moment, the alien soldier only fires a total of 3 torpedoes. 
        // The additional 2 are fired at a 30 degree angle to the left and right of the original torpedo.
        guard alien.cast == .soldier else { return }
        createTorpedo(gun: gun, position: position, velocity: velocity, rotationOffset: 30.0)
        createTorpedo(gun: gun, position: position, velocity: velocity, rotationOffset: -30.0)
    }

    func createTorpedo(gun: GunComponent, position: PositionComponent, velocity: VelocityComponent, rotationOffset: CGFloat) {
        let pos = PositionComponent(x: position.x,
                                    y: position.y,
                                    z: .asteroids,
                                    rotationDegrees: position.rotationDegrees + rotationOffset)
        torpedoCreator?.createTorpedo(gun, pos, velocity)
    }

    func targetWithinRange(_ targetedEntity: Entity, _ alien: AlienComponent, _ position: PositionComponent) -> Bool {
        guard let targetPosition = targetedEntity.find(componentClass: PositionComponent.self) else { return false }
        guard let _ = targetedEntity.find(componentClass: ShootableComponent.self) else { return false }
        let distance = hypot(targetPosition.x - position.x, targetPosition.y - position.y)
        return distance < alien.maxTargetableRange
    }
}
