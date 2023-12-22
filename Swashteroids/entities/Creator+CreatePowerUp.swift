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

extension Creator {
    func createPlasmaTorpedoesPowerUp(radius: Double = 7, level: Int) {
        guard engine.getEntity(named: .plasmaTorpedoesPowerUp) == nil else { return }
        let sprite = PlasmaTorpedoesPowerUpView(imageNamed: "scope")
        let emitter = SKEmitterNode(fileNamed: "plasmaTorpedoesPowerUp.sks")!
        sprite.addChild(emitter)
        let entity = Entity(name: .plasmaTorpedoesPowerUp)
        sprite.name = entity.name
        sprite.color = .plasmaTorpedo
        sprite.colorBlendFactor = 1.0
        let positionComponent = createRandomPosition(level: Double(level), layer: .asteroids)
        let motionComponent = createRandomMotion(level: Double(level))
        entity
                .add(component: GunPowerUpComponent())
                .add(component: positionComponent)
                .add(component: motionComponent)
                .add(component: CollisionComponent(radius: radius))
                .add(component: DisplayComponent(sknode: sprite))
                .add(component: AnimationComponent(animation: sprite))
        engine.replaceEntity(entity: entity)
    }

    func createHyperspacePowerUp(radius: Double = 7, level: Int) {
        guard engine.getEntity(named: .hyperspacePowerUp) == nil else { return }
        let sprite = HyperspacePowerUpView(imageNamed: "hyperspacePowerUp")
        let emitter = SKEmitterNode(fileNamed: "hyperspacePowerUp.sks")!
        sprite.addChild(emitter)
        let entity = Entity(name: .hyperspacePowerUp)
        sprite.name = entity.name
		sprite.color = .hyperspace
        sprite.colorBlendFactor = 1.0
        let positionComponent = createRandomPosition(level: Double(level), layer: .asteroids)
        let motionComponent = createRandomMotion(level: Double(level))
        entity
                .add(component: HyperspacePowerUpComponent())
                .add(component: positionComponent)
                .add(component: motionComponent)
                .add(component: CollisionComponent(radius: radius))
                .add(component: DisplayComponent(sknode: sprite))
                .add(component: AnimationComponent(animation: sprite))
        engine.replaceEntity(entity: entity)
    }

    private func createRandomPosition(level: Double, layer: Layer) -> PositionComponent {
        let r1 = Double.random(in: 75.0...(level * 130)) * [-1, 1].randomElement()!
        let r2 = Double.random(in: 75.0...(level * 100)) * [-1, 1].randomElement()!
		let centerX = min(size.width / 2.0 + r1, size.width)
		let centerY = min(size.height / 2.0 + r2, size.height)
        return PositionComponent(x: centerX, y: centerY, z: layer, rotation: 0.0)
    }

    private func createRandomMotion(level: Double) -> MotionComponent {
        let velocityX = Double.random(in: -10.0...10.0) * Double(level)
        let velocityY = Double.random(in: -10.0...10.0) * Double(level)
        let angularVelocity = Double.random(in: -100.0...100.0)
        return MotionComponent(velocityX: velocityX, velocityY: velocityY, angularVelocity: angularVelocity, dampening: 0)
    }
}
