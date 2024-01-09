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

extension Creator: PowerUpCreator {
    func createHyperspacePowerUp(level: Int) {
        createHyperspacePowerUp(level: level, radius: POWER_UP_RADIUS)
    }

    func createPlasmaTorpedoesPowerUp(level: Int) {
        createPlasmaTorpedoesPowerUp(level: level, radius: POWER_UP_RADIUS)
    }

    private func createEmitter(colored color: UIColor, on sprite: SKSpriteNode) {
        if let emitter = SKEmitterNode(fileNamed: "fireflies_mod.sks") {
            let colorRamp: [UIColor] = [color]
            let keyTimes: [NSNumber] = [1.0]
            let colorSequence = SKKeyframeSequence(keyframeValues: colorRamp, times: keyTimes)
            emitter.particleColorSequence = colorSequence
            sprite.addChild(emitter)
        }
    }

    func createPlasmaTorpedoesPowerUp(level: Int, radius: Double = POWER_UP_RADIUS) {
        guard engine.getEntity(named: .torpedoPowerUp) == nil else { return }
        let sprite = PlasmaTorpedoesPowerUpView(imageNamed: "torpedoPowerUp")
        createEmitter(colored: .powerUpTorpedo, on: sprite)
        let entity = Entity(named: .torpedoPowerUp)
        sprite.name = entity.name
        sprite.color = .powerUpTorpedo
        sprite.colorBlendFactor = 1.0
        let positionComponent = createRandomPosition(level: Double(level), layer: .asteroids)
        let velocityComponent = createRandomVelocity(level: Double(level))
        velocityComponent.angularVelocity = 25.0
        entity
                .add(component: GunPowerUpComponent())
                .add(component: positionComponent)
                .add(component: velocityComponent)
                .add(component: CollisionComponent(radius: radius))
                .add(component: DisplayComponent(sknode: sprite))
                .add(component: AnimationComponent(animation: sprite))
        engine.replace(entity: entity)
    }

    func createHyperspacePowerUp(level: Int, radius: Double = POWER_UP_RADIUS) {
        guard engine.getEntity(named: .hyperspacePowerUp) == nil else { return }
        let sprite = HyperspacePowerUpView(imageNamed: "hyperspacePowerUp")
        createEmitter(colored: .powerUpHyperspace, on: sprite)
        let entity = Entity(named: .hyperspacePowerUp)
        sprite.name = entity.name
        sprite.color = .powerUpHyperspace
        sprite.colorBlendFactor = 1.0
        let positionComponent = createRandomPosition(level: Double(level), layer: .asteroids)
        let velocityComponent = createRandomVelocity(level: Double(level))
        velocityComponent.angularVelocity = 25.0
        entity
                .add(component: HyperspacePowerUpComponent())
                .add(component: positionComponent)
                .add(component: velocityComponent)
                .add(component: CollisionComponent(radius: radius))
                .add(component: DisplayComponent(sknode: sprite))
                .add(component: AnimationComponent(animation: sprite))
        engine.replace(entity: entity)
    }

    private func createRandomPosition(level: Double, layer: Layer) -> PositionComponent {
        let r1 = Double.random(in: 75.0...(level * 130)) * [-1, 1].randomElement()!
        let r2 = Double.random(in: 75.0...(level * 100)) * [-1, 1].randomElement()!
        let centerX = min(size.width / 2.0 + r1, size.width)
        let centerY = min(size.height / 2.0 + r2, size.height)
        return PositionComponent(x: centerX, y: centerY, z: layer, rotationDegrees: 0.0)
    }

    private func createRandomVelocity(level: Double) -> VelocityComponent {
        let velocityX = Double.random(in: -10.0...10.0) * Double(level)
        let velocityY = Double.random(in: -10.0...10.0) * Double(level)
        return VelocityComponent(velocityX: velocityX, velocityY: velocityY, dampening: 0)
    }
}
