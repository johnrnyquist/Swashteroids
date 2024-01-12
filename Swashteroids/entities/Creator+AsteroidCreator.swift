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

extension Creator: AsteroidCreator {
    func createAsteroid(radius: Double, x: Double, y: Double, level: Int) {
        numAsteroids += 1
        let sprite = SwashSpriteNode(texture: createAsteroidTexture(radius: radius, color: .asteroid))
//        sprite.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(radius * scaleManager.SCALE_FACTOR))
//        sprite.physicsBody?.isDynamic = true
//        sprite.physicsBody?.affectedByGravity = false
//        sprite.physicsBody?.categoryBitMask = asteroidCategory
//        sprite.physicsBody?.contactTestBitMask =  playerCategory | torpedoCategory
//        sprite.physicsBody?.collisionBitMask = 0
        let entity = Entity()
        entity.name = .asteroid + "_\(numAsteroids)"
        sprite.name = entity.name
        let lvl = Double(level > 0 ? level : 1)
        let speedModifier = lvl * 0.1 + 1.0  // 1.1, 1.2, 1.3, 1.4
        entity
                .add(component: PositionComponent(x: x, y: y, z: .asteroids, rotationDegrees: 0.0))
                .add(component: VelocityComponent(velocityX: min(Double.random(in: -82.0...82.0) * speedModifier, 100.0),
                                                  velocityY: min(Double.random(in: -82.0...82.0) * speedModifier, 100.0),
                                                  angularVelocity: Double.random(in: -100.0...100.0),
                                                  dampening: 0,
                                                  base: 60.0))
                .add(component: CollisionComponent(radius: radius))
                .add(component: AsteroidComponent())
                .add(component: DisplayComponent(sknode: sprite))
        sprite.entity = entity
        do {
            try engine.add(entity: entity)
        } catch SwashError.entityNameAlreadyInUse(let message) {
            fatalError(message)
        } catch {
            fatalError("Unexpected error: \(error).")
        }
    }
}
