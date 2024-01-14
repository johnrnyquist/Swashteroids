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

    func createTorpedoesPowerUp(level: Int) {
        createTorpedoesPowerUp(level: level, radius: POWER_UP_RADIUS)
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

    func createPowerUp(level: Int,
                       radius: Double,
                       entityName: EntityName,
                       sprite: SwashSpriteNode,
                       color: UIColor,
                       component: Component) {
        guard engine.findEntity(named: entityName) == nil else { return }
        sprite.name = entityName
        sprite.color = color
        sprite.colorBlendFactor = 1.0
        addEmitter(colored: color, on: sprite)
        let entity = Entity(named: entityName)
        sprite.entity = entity
        let positionComponent = self.createRandomPosition(level: Double(level), layer: .asteroids)
        let velocityComponent = self.createRandomVelocity(level: Double(level))
        velocityComponent.angularVelocity = 25.0
        entity
                .add(component: DisplayComponent(sknode: sprite))
                .add(component: component)
                .add(component: positionComponent)
                .add(component: velocityComponent)
                .add(component: CollidableComponent(radius: radius))
                
        self.engine.replace(entity: entity)
        sprite.alpha = 0.0
        let alphaUp = SKAction.fadeAlpha(to: 1.0, duration: 0.5)
        let scaleUp = SKAction.scale(to: sprite.scale * 2.0, duration: 0.3)
        let scaleDown = SKAction.scale(to: sprite.scale, duration: 0.3)
        let waitToMake = SKAction.wait(forDuration: Double.random(in: 4.0...6.0))
        let action = SKAction.run { entity.add(component: AudioComponent(fileNamed: .powerUpAppearance, actionKey: "newPowerUp")) }
        let sequence = SKAction.sequence([waitToMake, alphaUp, action, scaleUp, scaleDown])
        sprite.run(sequence)
    }

    func createRandomPosition(level: Double, layer: Layer) -> PositionComponent {
        let r1 = Double.random(in: 75.0...(level * 130)) * [-1, 1].randomElement()!
        let r2 = Double.random(in: 75.0...(level * 100)) * [-1, 1].randomElement()!
        let centerX = min(size.width / 2.0 + r1, size.width)
        let centerY = min(size.height / 2.0 + r2, size.height)
        return PositionComponent(x: centerX, y: centerY, z: layer, rotationDegrees: 0.0)
    }

    func createRandomVelocity(level: Double) -> VelocityComponent {
        let velocityX = Double.random(in: -10.0...10.0) * Double(level)
        let velocityY = Double.random(in: -10.0...10.0) * Double(level)
        return VelocityComponent(velocityX: velocityX, velocityY: velocityY, dampening: 0, base: 60.0)
    }
}
