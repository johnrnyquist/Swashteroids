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
    func createAsteroid(radius: Double, x: Double, y: Double, level: Int, color: UIColor = .asteroid) {
        let sprite = SwashSpriteNode(texture: createAsteroidTexture(radius: radius, color: color))
        let entity = Entity()
        numAsteroids += 1
        entity.name = "asteroid_\(numAsteroids)"
        sprite.name = entity.name
        let lvl = Double(level > 0 ? level : 1)
        let speedModifier = lvl * 0.1 + 1.0  // 1.1, 1.2, 1.3, 1.4
        entity
                .add(component: PositionComponent(x: x, y: y, z: .asteroids, rotation: 0.0))
                .add(component: MotionComponent(velocityX: min(Double.random(in: -82.0...82.0) * speedModifier, 100.0),
                                                velocityY: min(Double.random(in: -82.0...82.0) * speedModifier, 100.0),
                                                angularVelocity: Double.random(in: -100.0...100.0),
                                                dampening: 0))
                .add(component: CollisionComponent(radius: radius * SCALE_FACTOR))
                .add(component: AsteroidComponent())
                .add(component: DisplayComponent(sknode: sprite))
        
        do {
            try engine.addEntity(entity: entity)
        } catch SwashError.entityNameAlreadyInUse(let message) {
            fatalError(message)
        } catch {
            fatalError("Unexpected error: \(error).")
        }
    }
}
