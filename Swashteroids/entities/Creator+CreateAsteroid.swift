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
    func createAsteroid(radius: Double, x: Double, y: Double, color: UIColor = .asteroid) {
        let sprite = SwashteroidsSpriteNode(texture: createAsteroidTexture(radius: radius, color: color))
        let entity = Entity()
        numAsteroids += 1
        entity.name = "asteroid_\(numAsteroids)"
        sprite.name = entity.name
        entity
                .add(component: PositionComponent(x: x, y: y, z: .asteroids, rotation: 0.0))
                .add(component: MotionComponent(velocityX: Double.random(in: -82.0...82.0),
                                                velocityY: Double.random(in: -82.0...82.0),
                                                angularVelocity: Double.random(in: -100.0...100.0),
                                                damping: 0))
                .add(component: CollisionComponent(radius: radius))
                .add(component: AsteroidComponent())
                .add(component: DisplayComponent(sknode: sprite))
                .add(component: AudioComponent())
        try! engine.addEntity(entity: entity)
    }

    func createAsteroids(_ n: Int) {
        for _ in 1...n {
            createAsteroid(radius: LARGE_ASTEROID_RADIUS,
                           x: Double.random(in: 0.0...1024.0),
                           y: Double.random(in: 0...768.0))
        }
    }
}
