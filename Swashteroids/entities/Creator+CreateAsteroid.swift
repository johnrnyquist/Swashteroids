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
    func createAsteroid(radius: Double, x: Double, y: Double, color: UIColor = .asteroid, level: Int) {
        let sprite = SwashteroidsSpriteNode(texture: createAsteroidTexture(radius: radius, color: color))
        let entity = Entity()
        numAsteroids += 1
        entity.name = "asteroid_\(numAsteroids)"
        sprite.name = entity.name
        entity
                .add(component: PositionComponent(x: x, y: y, z: .asteroids, rotation: 0.0))
                .add(component: MotionComponent(velocityX: min(Double.random(in: -82.0...82.0) * Double(level), 100.0),
                                                velocityY: min(Double.random(in: -82.0...82.0) * Double(level), 100.0),
                                                angularVelocity: Double.random(in: -100.0...100.0),
                                                damping: 0))
                .add(component: CollisionComponent(radius: radius))
                .add(component: AsteroidComponent())
                .add(component: DisplayComponent(sknode: sprite))
        try! engine.addEntity(entity: entity)
    }
}
