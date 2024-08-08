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

enum PowerUpType {
    case torpedoes
    case hyperspace
    case xRay
    case shields
    var entityName: EntityName {
        switch self {
            case .torpedoes:
                return .torpedoPowerUp
            case .hyperspace:
                return .hyperspacePowerUp
            case .xRay:
                return .xRayPowerUp
            case .shields:
                return .shieldPowerUp
        }
    }
    var imageName: String {
        switch self {
            case .torpedoes:
                return AssetImage.torpedoPowerUp.name
            case .hyperspace:
                return AssetImage.hyperspacePowerUp.name
            case .xRay:
                return AssetImage.xray.name
            case .shields:
                return AssetImage.shield.name
        }
    }
    var createSprite: SwashScaledSpriteNode {
        let sprite: SwashScaledSpriteNode
        switch self {
            case .torpedoes:
                sprite = TorpedoesPowerUpView(imageNamed: imageName)
            case .hyperspace:
                sprite = HyperspacePowerUpView(imageNamed: imageName)
            case .xRay:
                sprite = SwashScaledSpriteNode(imageNamed: imageName)
            case .shields:
                sprite = SwashScaledSpriteNode(imageNamed: imageName)
        }
        sprite.name = entityName
        sprite.color = color
        sprite.colorBlendFactor = 1.0
        sprite.alpha = 0.0
        return sprite
    }
    var color: UIColor {
        switch self {
            case .torpedoes:
                return .powerUpTorpedo
            case .hyperspace:
                return .powerUpHyperspace
            case .xRay:
                return .powerUpXRay
            case .shields:
                return .shields
        }
    }
    var radius: Double {
        switch self {
            case .torpedoes:
                return 7.0
            case .hyperspace:
                return 7.0
            case .xRay:
                return 7.0
            case .shields:
                return 7.0
        }
    }
    var createComponent: Component {
        switch self {
            case .torpedoes:
                return GunPowerUpComponent()
            case .hyperspace:
                return HyperspacePowerUpComponent()
            case .xRay:
                return XRayPowerUpComponent()
            case .shields:
                return ShieldPowerUpComponent()
        }
    }

    func createEntity(level: Int, at positionComponent: PositionComponent) -> Entity {
        let entity = Entity(named: entityName)
        let velocityComponent = createRandomVelocity(level: Double(level))
        switch self {
            case .torpedoes:
                velocityComponent.angularVelocity = 25.0
            case .hyperspace:
                velocityComponent.angularVelocity = 25.0
            case .xRay:
                velocityComponent.angularVelocity = 0.0
            case .shields:
                velocityComponent.angularVelocity = 0.0
        }
        let sprite = createSprite
        let component = createComponent
        entity
                .add(component: component)
                .add(component: DisplayComponent(sknode: sprite))
                .add(component: positionComponent)
                .add(component: velocityComponent)
        sprite.swashEntity = entity
        return entity
    }

    func createRandomPosition(avoiding avoidPoint: CGPoint? = nil, level: Double, gameSize: CGSize, layer: Layer, randomness: Randomizing = Randomness.shared) -> PositionComponent {
        // Use the point to avoid or default to the center of the game area
        let point = avoidPoint ?? CGPoint(x: gameSize.halfWidth, y: gameSize.halfHeight)
        let dir = [-1.0, 1.0]
        let minValue: Double = 75.0
        let maxX: Double = level * 130.0
        let maxY: Double = level * 100.0
        let maxAttempts = 100 // Maximum number of attempts to find a valid position
        // Function to generate a random position within the game boundaries
        func generateRandomPosition() -> CGPoint {
            let r1 = randomness.nextDouble(from: minValue, through: maxX) * dir[randomness.nextInt(upTo: dir.count)]
            let r2 = randomness.nextDouble(from: minValue, through: maxY) * dir[randomness.nextInt(upTo: dir.count)]
            let x = min(max(point.x + r1, 0), gameSize.width)
            let y = min(max(point.y + r2, 0), gameSize.height)
            return CGPoint(x: x, y: y)
        }

        var randomPoint: CGPoint
        var attempts = 0
        // Generate random positions until a valid one is found or max attempts are reached
        repeat {
            randomPoint = generateRandomPosition()
            attempts += 1
        } while point.distance(from: randomPoint) < minValue && attempts < maxAttempts
        // Return the generated position as a PositionComponent
        return PositionComponent(x: randomPoint.x, y: randomPoint.y, z: layer, rotationDegrees: 0.0)
    }

    private func createRandomVelocity(level: Double, randomness: Randomizing = Randomness.shared) -> VelocityComponent {
        let velocityX = randomness.nextDouble(from: -10.0, through: 10.0) * Double(level)
        let velocityY = randomness.nextDouble(from: -10.0, through: 10.0) * Double(level)
        return VelocityComponent(velocityX: velocityX, velocityY: velocityY, dampening: 0, base: 60.0)
    }
}

final class PowerUpCreator: PowerUpCreatorUseCase {
    private let size: CGSize
    private weak var engine: Engine!
    private weak var randomness: Randomizing!

    init(engine: Engine, size: CGSize, randomness: Randomizing = Randomness.shared) {
        self.engine = engine
        self.size = size
        self.randomness = randomness
    }

    func createPowerUp(level: Int, type: PowerUpType) {
        createPowerUp(level: level, type: type, avoiding: nil)
    }

    func createPowerUp(level: Int, type: PowerUpType, avoiding point: CGPoint?) {
        guard engine.findEntity(named: type.entityName) == nil else { return }
        let positionComponent = type.createRandomPosition(avoiding: point, level: Double(level), gameSize: size, layer: .powerUps)
        let entity = type.createEntity(level: level, at: positionComponent)
        let sprite = entity.sprite!
        addEmitter(colored: type.color, on: entity[DisplayComponent.self]!.sknode)
        engine.add(entity: entity)
        let alphaUp = SKAction.fadeAlpha(to: 1.0, duration: 0.5)
        let scaleUp = SKAction.scale(to: sprite.scale * 2.0, duration: 0.3)
        let scaleDown = SKAction.scale(to: sprite.scale, duration: 0.3)
        let waitToMake = SKAction.wait(forDuration: randomness.nextDouble(from: 4.0, through: 6.0))
        let action = SKAction.run {
            entity
                    .add(component: AudioComponent(asset: .powerup_appearance))
                    .add(component: CollidableComponent(radius: type.radius))
            switch type {
                case .torpedoes:
                    break
                case .hyperspace:
                    break
                case .xRay:
                    entity.add(component: LifetimeComponent(timeRemaining: 30, numberOfFlashes: 5))
                case .shields:
                    entity.add(component: LifetimeComponent(timeRemaining: 30, numberOfFlashes: 5))
            }
        }
        let sequence = SKAction.sequence([waitToMake, alphaUp, action, scaleUp, scaleDown])
        sprite.run(sequence)
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
