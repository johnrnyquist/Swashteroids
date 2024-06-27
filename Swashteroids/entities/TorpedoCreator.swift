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

class TorpedoCreator: TorpedoCreatorUseCase {
    private weak var engine: Engine!
    private weak var scaleManager: ScaleManaging!

    init(engine: Engine, scaleManager: ScaleManaging = ScaleManager.shared) {
        self.engine = engine
        self.scaleManager = scaleManager
    }

    func createTorpedo(_ gunComponent: GunComponent, _ position: PositionComponent, _ velocity: VelocityComponent) {
        let name = generateTorpedoName()
        let entity = createTorpedoEntity(named: name,
                                         gunComponent: gunComponent,
                                         parentPosition: position,
                                         parentVelocity: velocity)
        engine.add(entity: entity)
    }

    // TODO: This changing of an existing component does not feel right.
    func generateTorpedoName() -> String {
        engine.appStateComponent.numTorpedoesFired += 1
        return "torpedo_\(engine.appStateComponent.numTorpedoesFired)"
    }

    func createTorpedoEntity(named name: String, gunComponent: GunComponent, parentPosition: PositionComponent, parentVelocity: VelocityComponent) -> Entity {
        // DisplayComponent
        let emitter = setupEmitter(gunComponent: gunComponent, position: parentPosition)
        let sprite = setupSprite(named: name, emitter: emitter, gunComponent: gunComponent, position: parentPosition)
        let displayComponent = DisplayComponent(sknode: sprite)
        // PositionComponent
        let (x, y) = calculatePosition(gunComponent: gunComponent, parentPosition: parentPosition)
        let torpedoPosition = PositionComponent(x: x, y: y, z: Layer.torpedoes, rotationDegrees: 0)
        // VelocityComponent
        let torpedoVelocity = calculateVelocity(gunComponent: gunComponent, parentPosition: parentPosition, parentVelocity: parentVelocity)
        // TorpedoComponent
        let torpedoComponent = TorpedoComponent(lifeRemaining: gunComponent.torpedoLifetime,
                                                owner: gunComponent.ownerType,
                                                ownerName: gunComponent.ownerName)
        let torpedo = Entity(named: name)
        torpedo
                .add(component: torpedoPosition)
                .add(component: torpedoVelocity)
                .add(component: displayComponent)
                .add(component: AudioComponent(fileNamed: .launchTorpedo, actionKey: name))
                .add(component: CollidableComponent(radius: 0))
                .add(component: torpedoComponent)
        sprite.entity = torpedo
        return torpedo
    }

    func calculatePosition(gunComponent: GunComponent, parentPosition: PositionComponent) -> (Double, Double) {
        let cos = cos(parentPosition.rotationRadians)
        let sin = sin(parentPosition.rotationRadians)
        let x = cos * gunComponent.offsetFromParent.x - sin * gunComponent.offsetFromParent.y + parentPosition.x
        let y = sin * gunComponent.offsetFromParent.x + cos * gunComponent.offsetFromParent.y + parentPosition.y
        return (x, y)
    }

    func calculateVelocity(gunComponent: GunComponent, parentPosition: PositionComponent, parentVelocity: VelocityComponent) -> VelocityComponent {
        let cos = cos(parentPosition.rotationRadians)
        let sin = sin(parentPosition.rotationRadians)
        // TODO: 220 is a magic number. Unscale parent velocity because it will get scaled again when passed to the VelocityComponent
        let velocityX = cos * 220 + parentVelocity.linearVelocity.x / scaleManager.SCALE_FACTOR
        let velocityY = sin * 220 + parentVelocity.linearVelocity.y / scaleManager.SCALE_FACTOR
        return VelocityComponent(velocityX: velocityX,
                                 velocityY: velocityY,
                                 angularVelocity: parentVelocity.angularVelocity,
                                 dampening: parentVelocity.dampening,
                                 base: 60.0)
    }

    func setupSprite(named name: String, emitter: SKEmitterNode, gunComponent: GunComponent, position: PositionComponent) -> SwashScaledSpriteNode {
        let sprite = SwashScaledSpriteNode(texture: createTorpedoTexture(color: gunComponent.torpedoColor))
        sprite.name = name
        sprite.zPosition = .asteroids
        sprite.addChild(emitter)
        return sprite
    }

    func setupEmitter(gunComponent: GunComponent, position: PositionComponent) -> SKEmitterNode {
        let emitter = SKEmitterNode(fileNamed: "plasmaTorpedo.sks")!
        let colorRamp: [UIColor] = [gunComponent.torpedoColor]
        let keyTimes: [NSNumber] = [1.0]
        let colorSequence = SKKeyframeSequence(keyframeValues: colorRamp, times: keyTimes)
        emitter.particleColorSequence = colorSequence
        emitter.emissionAngle = position.rotationRadians + Double.pi
        return emitter
    }

    func createTorpedo2(_ gunComponent: GunComponent, _ position: PositionComponent, _ velocity: VelocityComponent) {
        //TODO: this should be re-thought
        var name = "torpedo_"
        guard let appStateEntity = engine.findEntity(named: .appState),
              let appStateComponent = appStateEntity[SwashteroidsStateComponent.self]
        else {
            fatalError("Could not find AppStateComponent.")
        }
        // TODO: This changing of an existing component does not feel right.
        appStateComponent.numTorpedoesFired += 1
        name += "\(appStateComponent.numTorpedoesFired)"
        //
        let entity = Entity(named: name)
        let emitter = SKEmitterNode(fileNamed: "plasmaTorpedo.sks")!
        let colorRamp: [UIColor] = [gunComponent.torpedoColor]
        let keyTimes: [NSNumber] = [1.0]
        let colorSequence = SKKeyframeSequence(keyframeValues: colorRamp, times: keyTimes)
        let cos = cos(position.rotationRadians)
        let sin = sin(position.rotationRadians)
        let sprite = SwashScaledSpriteNode(texture: createTorpedoTexture(color: gunComponent.torpedoColor))
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
        engine.add(entity: entity)
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
                                                 ownerName: gunComponent.ownerName))
    }
}
