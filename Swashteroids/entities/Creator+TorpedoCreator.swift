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

extension Creator: TorpedoCreator {
    func createTorpedo(_ gunComponent: GunComponent, _ position: PositionComponent, _ velocity: VelocityComponent) {
        //TODO: this should be re-thought
        var name = "torpedo_"
        if let appStateEntity = engine.findEntity(named: .appState),
           let appStateComponent = appStateEntity[AppStateComponent.self] {
            appStateComponent.numTorpedoesFired += 1
            name += "\(appStateComponent.numTorpedoesFired)"
        } else {
            name += UUID().uuidString
        }
        //
        let entity = Entity(named: name)
        let emitter = SKEmitterNode(fileNamed: "plasmaTorpedo.sks")!
        let colorRamp: [UIColor] = [gunComponent.torpedoColor]
        let keyTimes: [NSNumber] = [1.0]
        let colorSequence = SKKeyframeSequence(keyframeValues: colorRamp, times: keyTimes)
        let cos = cos(position.rotationRadians)
        let sin = sin(position.rotationRadians)
        let sprite = SwashSpriteNode(texture: createTorpedoTexture(color: gunComponent.torpedoColor))
        //
//        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
//        sprite.physicsBody?.isDynamic = true
//        sprite.physicsBody?.affectedByGravity = false
//        sprite.physicsBody?.categoryBitMask = torpedoCategory
//        sprite.physicsBody?.contactTestBitMask = asteroidCategory | playerCategory | alienCategory
        sprite.entity = entity
        sprite.addChild(emitter)
        sprite.name = entity.name
        sprite.zPosition = .asteroids
        emitter.particleColorSequence = colorSequence
        emitter.emissionAngle = position.rotationRadians + Double.pi
        do {
            try engine.add(entity: entity)
            print("\(entity.name) created by \(gunComponent.ownerEntity.name)")
        } catch SwashError.entityNameAlreadyInUse(let message) {
            fatalError(message)
        } catch {
            fatalError("Unexpected error: \(error).")
        }
        entity
                .add(component: PositionComponent(
                    x: cos * gunComponent.offsetFromParent.x - sin * gunComponent.offsetFromParent.y + position.x,
                    y: sin * gunComponent.offsetFromParent.x + cos * gunComponent.offsetFromParent.y + position.y,
                    z: Layer.torpedoes,
                    rotationDegrees: 0))
                .add(component: VelocityComponent(velocityX: cos * 220 + velocity.linearVelocity
                                                                                 .x * 1.0 / scaleManager.SCALE_FACTOR,
                                                  velocityY: sin * 220 + velocity.linearVelocity
                                                                                 .y * 1.0 / scaleManager.SCALE_FACTOR,
                                                  angularVelocity: 0 + velocity.angularVelocity,
                                                  dampening: 0 + velocity.dampening,
                                                  base: 60.0))
                .add(component: DisplayComponent(sknode: sprite))
                .add(component: AudioComponent(fileNamed: .launchTorpedo, actionKey: name))
                .add(component: CollidableComponent(radius: 0))
                .add(component: TorpedoComponent(lifeRemaining: gunComponent.torpedoLifetime,
                                                 owner: gunComponent.ownerType,
                                                 ownerEntity: gunComponent.ownerEntity))
    }
}
