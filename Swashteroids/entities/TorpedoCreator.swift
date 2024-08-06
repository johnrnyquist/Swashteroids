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

final class TorpedoCreator: TorpedoCreatorUseCase {
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

    // HACK: This changing of an existing component does not feel right.
    func generateTorpedoName() -> String {
        engine.gameStateComponent.numTorpedoesFired += 1
        return "torpedo_\(engine.gameStateComponent.numTorpedoesFired)"
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
        let torpedoVelocity = calculateVelocity(gunComponent: gunComponent,
                                                parentPosition: parentPosition,
                                                parentVelocity: parentVelocity)
        // TorpedoComponent
        let torpedoComponent = TorpedoComponent(lifeRemaining: gunComponent.torpedoLifetime,
                                                owner: gunComponent.ownerType,
                                                ownerName: gunComponent.ownerName)
        let torpedo = Entity(named: name)
        torpedo
                .add(component: LifetimeComponent(timeRemaining: gunComponent.torpedoLifetime))
                .add(component: torpedoPosition)
                .add(component: torpedoVelocity)
                .add(component: displayComponent)
                .add(component: AudioComponent(asset: .launch_torpedo))
                .add(component: CollidableComponent(radius: 0))
                .add(component: torpedoComponent)
        sprite.swashEntity = torpedo
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
}
