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

final class AsteroidCreator: AsteroidCreatorUseCase {
    private let engine: Engine
    private var totalAsteroids = 0
    private weak var randomness: Randomizing!
    private weak var scaleManager: ScaleManaging!
    private weak var treasureCreator: TreasureCreatorUseCase?

    init(engine: Engine,
         treasureCreator: TreasureCreatorUseCase,
         randomness: Randomizing = Randomness.shared,
         scaleManager: ScaleManaging = ScaleManager.shared) {
        self.engine = engine
        self.treasureCreator = treasureCreator
        self.randomness = randomness
        self.scaleManager = scaleManager
    }

    /// Create an asteroid with the given radius, x, y, and level.
    /// 
    /// - Parameters:
    ///   - radius: The radius of the asteroid.
    ///   - x: The x position of the asteroid.
    ///   - y: The y position of the asteroid.
    ///   - size: The size of the asteroid.
    ///   - level: This is the Game's current level. Value is used to determine the speed of the asteroid.
    @discardableResult
    func createAsteroid(radius: Double, x: Double, y: Double, size: AsteroidSize, level: Int) -> Entity {
        totalAsteroids += 1
        let sprite = SwashScaledSpriteNode(texture: createAsteroidTexture(radius: radius, color: .asteroid))
//        sprite.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(radius * scaleManager.SCALE_FACTOR))
//        sprite.physicsBody?.isDynamic = true
//        sprite.physicsBody?.affectedByGravity = false
//        sprite.physicsBody?.categoryBitMask = asteroidCategory
//        sprite.physicsBody?.contactTestBitMask =  playerCategory | torpedoCategory
//        sprite.physicsBody?.collisionBitMask = 0
        let entity = Entity(named: .asteroid + "_\(totalAsteroids)")
        sprite.name = entity.name
        let lvl = Double(level > 0 ? level : 1)
        let speedModifier = lvl * 0.1 + 1.0  // 1.1, 1.2, 1.3, 1.4
        entity
                .add(component: PositionComponent(x: x, y: y, z: .asteroids, rotationDegrees: 0.0))
                .add(component: createVelocity(speedModifier: speedModifier, level: Int(lvl)))
                .add(component: CollidableComponent(radius: radius * 0.9))
                .add(component: AsteroidComponent(size: size))
                .add(component: DisplayComponent(sknode: sprite))
                .add(component: AlienCanShootComponent.shared)
                .add(component: AlienWorkerTargetComponent.shared)
        if randomness.nextInt(from: 1, through: 3) == 1 {
            let type: TreasureType
            if randomness.nextInt(from: 1, through: 5) == 5 {
                type = .special
            } else {
                type = .standard
            }
            entity.add(component: TreasureInfoComponent(of: type))
        }
        sprite.swashEntity = entity
        engine.add(entity: entity)
        return entity
    }

    func createAsteroidTexture(radius: Double, color: UIColor) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: radius * 2, height: radius * 2))
        let asteroid = renderer.image { ctx in
            ctx.cgContext.translateBy(x: radius, y: radius) // move to center
            ctx.cgContext.setStrokeColor(color.cgColor)
            ctx.cgContext.setLineWidth(LINE_WIDTH)
            var angle = 0.0
            ctx.cgContext.move(to: CGPoint(x: radius, y: 0.0))
            while angle < (Double.pi * 2) {
                let length = (0.75 + randomness.nextDouble(from: 0.0, through: 0.25)) * radius
                let posX = cos(angle) * length
                let posY = sin(angle) * length
                let point = CGPoint(x: posX, y: posY)
                ctx.cgContext.addLine(to: point)
                angle += randomness.nextDouble(from: 0.0, through: 0.5)
            }
            ctx.cgContext.addLine(to: CGPoint(x: radius, y: 0.0))
            ctx.cgContext.strokePath()
        }
        return SKTexture(image: asteroid)
    }
}

func createVelocity(speedModifier: Double, level: Int, randomness: Randomizing = Randomness.shared) -> VelocityComponent {
    var vx = 0.0
    while abs(vx) < 10.0 {
        vx = randomness.nextDouble(from: -82.0, through: 82.0) * speedModifier
    }
    var vy = 0.0
    while abs(vy) < 10.0 {
        vy = randomness.nextDouble(from: -82.0, through: 82.0) * speedModifier
    }
    let angularVelocity = randomness.nextDouble(from: -100, through: 100)
    return VelocityComponent(velocityX: vx,
                             velocityY: vy,
                             angularVelocity: angularVelocity,
                             dampening: 0,
                             base: 60.0)
}
