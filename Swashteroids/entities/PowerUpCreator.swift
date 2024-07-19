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

class PowerUpCreator: PowerUpCreatorUseCase {
    private let size: CGSize
    private weak var engine: Engine!
    private weak var randomness: Randomizing!

    init(engine: Engine, size: CGSize, randomness: Randomizing = Randomness.shared) {
        self.engine = engine
        self.size = size
        self.randomness = randomness
    }
    
    func createTorpedoesPowerUp(level: Int, radius: Double = POWER_UP_RADIUS) {
        createPowerUp(level: level,
                      radius: radius,
                      entityName: .torpedoPowerUp,
                      sprite: TorpedoesPowerUpView(imageNamed: .torpedoPowerUp),
                      color: .powerUpTorpedo,
                      component: GunPowerUpComponent()
        )
    }

    func createHyperspacePowerUp(level: Int, radius: Double = POWER_UP_RADIUS) {
        createPowerUp(level: level,
                      radius: radius,
                      entityName: .hyperspacePowerUp,
                      sprite: HyperspacePowerUpView(imageNamed: .hyperspacePowerUp),
                      color: .powerUpHyperspace,
                      component: HyperspacePowerUpComponent())
    }

    func createXRayPowerUp(level: Int, radius: Double = POWER_UP_RADIUS) {
        createPowerUp(level: level,
                      radius: radius,
                      entityName: .xRayPowerUp,
                      sprite: SwashScaledSpriteNode(imageNamed: "visionpro.circle"),
                      color: .powerUpXRay,
                      component: XRayPowerUpComponent())
    }

    func createShieldsPowerUp(radius: Double = POWER_UP_RADIUS) {
        createPowerUp(level: 1, 
                      radius: radius, 
                      entityName: .shieldsPowerUp, 
                      sprite: SwashScaledSpriteNode(imageNamed: "circle.dotted.circle"), 
                      color: .shields, 
                      component: ShieldsPowerUpComponent())
    }

    private func createPowerUp(level: Int,
                               radius: Double,
                               entityName: EntityName,
                               sprite: SwashScaledSpriteNode,
                               color: UIColor,
                               component: Component) {
        guard engine.findEntity(named: entityName) == nil else { return }
        sprite.name = entityName
        sprite.color = color
        sprite.colorBlendFactor = 1.0
        addEmitter(colored: color, on: sprite)
        let entity = Entity(named: entityName)
        sprite.entity = entity
        let positionComponent = createRandomPosition(level: Double(level), layer: .asteroids)
        let velocityComponent = createRandomVelocity(level: Double(level))
        velocityComponent.angularVelocity = 25.0
        entity
                .add(component: DisplayComponent(sknode: sprite))
                .add(component: component)
                .add(component: positionComponent)
                .add(component: velocityComponent)
                .add(component: CollidableComponent(radius: radius))
        //HACK
        if type(of: component) == XRayPowerUpComponent.self || type(of: component) == ShieldsPowerUpComponent.self {
            velocityComponent.angularVelocity = 0.0
            entity.add(component: LifetimeComponent(timeRemaining: 30))
        }
        self.engine.add(entity: entity)
        sprite.alpha = 0.0
        let alphaUp = SKAction.fadeAlpha(to: 1.0, duration: 0.5)
        let scaleUp = SKAction.scale(to: sprite.scale * 2.0, duration: 0.3)
        let scaleDown = SKAction.scale(to: sprite.scale, duration: 0.3)
        let waitToMake = SKAction.wait(forDuration: randomness.nextDouble(from: 4.0, through: 6.0))
        let action = SKAction.run { entity.add(component: AudioComponent(name: "newPowerUp", fileName: .powerUpAppearance)) }
        let sequence = SKAction.sequence([waitToMake, alphaUp, action, scaleUp, scaleDown])
        sprite.run(sequence)
    }

    private func createRandomPosition(level: Double, layer: Layer) -> PositionComponent {
        let dir = [-1.0, 1.0]
        let r1 = randomness.nextDouble(from: 75.0, through: level * 130.0) * dir[randomness.nextInt(upTo: dir.count)]
        let r2 = randomness.nextDouble(from: 75.0, through: level * 100) * dir[randomness.nextInt(upTo: dir.count)]
        let centerX = min(size.width / 2.0 + r1, size.width)
        let centerY = min(size.height / 2.0 + r2, size.height)
        return PositionComponent(x: centerX, y: centerY, z: layer, rotationDegrees: 0.0)
    }

    private func createRandomVelocity(level: Double) -> VelocityComponent {
        let velocityX = randomness.nextDouble(from: -10.0, through: 10.0) * Double(level)
        let velocityY = randomness.nextDouble(from: -10.0, through: 10.0) * Double(level)
        return VelocityComponent(velocityX: velocityX, velocityY: velocityY, dampening: 0, base: 60.0)
    }

    private func addEmitter(colored color: UIColor, on sknode: SKNode) {
        if let emitter = SKEmitterNode(fileNamed: "fireflies_mod.sks") {
            // emitter.setScale(1.0 * scaleManager.SCALE_FACTOR)
//             let colorRamp: [UIColor] = [color.lighter(by: 30.0).shiftHue(by: 10.0)]
            let colorRamp: [UIColor] = [color.shiftHue(by: 3.0)]
            let keyTimes: [NSNumber] = [1.0]
            let colorSequence = SKKeyframeSequence(keyframeValues: colorRamp, times: keyTimes)
            emitter.particleAlpha = 0.8
            emitter.particleColorSequence = colorSequence
            sknode.addChild(emitter)
        }
    }
}
