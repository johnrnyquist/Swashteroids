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

class AlienCreator: AlienCreatorUseCase {
    private let size: CGSize
    private var totalAliens = 0
    private weak var engine: Engine!
    private weak var randomness: Randomizing!

    init(engine: Engine, size: CGSize, randomness: Randomizing = Randomness.shared) {
        self.engine = engine
        self.size = size
        self.randomness = randomness
    }

    //TODO: scene is passed in because warningAliens needs to add a warning sprite to the scene, need to do this better
    func createAliens(scene: GameScene) {
        guard engine.findEntity(named: .player) != nil else { return }
        let entrance = pickEntrance()
        warningAliens(scene: scene, leftSide: entrance.leftSide)
        engine.appStateEntity.add(component: AudioComponent(fileNamed: .alienEntrance, actionKey: "alienEntrance"))
        createSoldier(entrance: entrance)
//        createTwoWorkers(entrance: entrance)
        return
//        switch totalAliens {
//        case 0...1:
//            createAlienWorker(startDestination: CGPoint(x: entrance.startDestination.x, y: entrance.startDestination.y + 50),
//                              endDestination: entrance.endDestination)
//        case 2...3:
//            switch randomness.nextBool() {
//            case true:
//                createTwoWorkers(entrance: entrance)
//            case false:
//                createAlienWorker(startDestination: CGPoint(x: entrance.startDestination.x,
//                                                            y: entrance.startDestination.y + 50),
//                                  endDestination: entrance.endDestination)
//            }
//        case 4...5:
//            switch randomness.nextInt(from: 1, through: 3) {
//            case 1:
//                createTwoWorkers(entrance: entrance)
//            case 2:
//                createSoldier(entrance: entrance)
//            case 3:
//                createAlienWorker(startDestination: CGPoint(x: entrance.startDestination.x,
//                                                            y: entrance.startDestination.y + 50),
//                                  endDestination: entrance.endDestination)
//            default:
//                break
//            }
//        default:
//            switch randomness.nextInt(from: 1, through: 5) {
//            case 1:
//                createTwoWorkers(entrance: entrance)
//            case 2:
//                createAlienWorker(startDestination: CGPoint(x: entrance.startDestination.x,
//                                                            y: entrance.startDestination.y + 50),
//                                  endDestination: entrance.endDestination)
//            case 3:
//                createSoldier(entrance: entrance)
//            case 4:
//                createAlienWorker(startDestination: CGPoint(x: entrance.startDestination.x,
//                                                            y: entrance.startDestination.y + 50),
//                                  endDestination: entrance.endDestination)
//                createSoldier(entrance: entrance)
//            case 5:
//                createTwoWorkers(entrance: entrance)
//                createSoldier(entrance: entrance)
//            default:
//                break
//            }
//        }
    }

    func createSoldier(entrance: (startDestination: CGPoint, endDestination: CGPoint, leftSide: Bool)) {
        createAlienSoldier(startDestination: entrance.startDestination, endDestination: entrance.endDestination)
    }

    func createTwoWorkers(entrance: (startDestination: CGPoint, endDestination: CGPoint, leftSide: Bool)) {
        createAlienWorker(startDestination: CGPoint(x: entrance.startDestination.x, y: entrance.startDestination.y + 50),
                          endDestination: entrance.endDestination)
        createAlienWorker(startDestination: CGPoint(x: entrance.startDestination.x, y: entrance.startDestination.y - 50),
                          endDestination: entrance.endDestination)
    }

    /// Picks a random entrance for the aliens
    /// 
    /// This method depends on the following properties of the Creator:
    /// - size: The size of the scene
    /// - randomness: A Randomness instance
    /// 
    /// - Returns: A tuple with the start and end destinations and a boolean indicating if the entrance is on the left side
    func pickEntrance() -> (startDestination: CGPoint, endDestination: CGPoint, leftSide: Bool) {
        let left = CGPoint(x: -200, //-sprite.width * 3,
                           y: randomness.nextDouble(from: 40, through: size.height - 40))
        let right = CGPoint(x: size.width + 200, //sprite.width * 3,
                            y: randomness.nextDouble(from: 40, through: size.height - 40))
        var startDestination: CGPoint
        var endDestination: CGPoint
        let leftSide: Bool
        switch randomness.nextBool() {
        case true:
            leftSide = true
            startDestination = left
            endDestination = right
        case false:
            leftSide = false
            startDestination = right
            endDestination = left
        }
        return (startDestination: startDestination, endDestination: endDestination, leftSide: leftSide)
    }

    // TODO: Fix this, it's a hack. Adding to the scene should not be done in a Creator, it should be in a System.
    func warningAliens(scene: GameScene, leftSide: Bool) {
        //HACK for immediate gratification
        let warningSprite: SKSpriteNode
        if leftSide {
            warningSprite = SKSpriteNode(imageNamed: "gradientLeft")
        } else {
            warningSprite = SKSpriteNode(imageNamed: "gradientRight")
        }
        scene.addChild(warningSprite)
        warningSprite.scale = scene.size.height / warningSprite.height
        warningSprite.anchorPoint = .zero
        warningSprite.zPosition = .bottom
        if leftSide {
            warningSprite.x = 0
        } else {
            warningSprite.x = scene.size.width - warningSprite.width
        }
        let turnRed = SKAction.customAction(withDuration: 0.1) { _, _ in
            warningSprite.color = .alienWarning
            warningSprite.colorBlendFactor = 1.0
        }
        let turnBlack = SKAction.customAction(withDuration: 0.1) { _, _ in
            warningSprite.color = .background
            warningSprite.colorBlendFactor = 1.0
        }
        //
        let remove = SKAction.removeFromParent()
        let singleFlash = SKAction.sequence([turnRed, turnBlack])
        let flashing = SKAction.repeat(singleFlash, count: 4)
        let sequence = SKAction.sequence([flashing, remove])
        warningSprite.run(sequence)
    }

    func createAlienWorker(startDestination: CGPoint, endDestination: CGPoint) {
        guard engine.findEntity(named: .player) != nil else { return }
        totalAliens += 1
        let sprite = SwashScaledSpriteNode(imageNamed: .alienWorker)
        sprite.name = "\(EntityName.alienWorker)_\(totalAliens)"
//        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
//        sprite.physicsBody?.isDynamic = true
//        sprite.physicsBody?.affectedByGravity = false
//        sprite.physicsBody?.categoryBitMask = alienCategory
//        sprite.physicsBody?.contactTestBitMask = asteroidCategory | playerCategory | torpedoCategory
        let workerComponent = AlienComponent(cast: .worker,
                                             reactionTime: randomness.nextDouble(from: 0.4, through: 0.8),
                                             scoreValue: 50)
        workerComponent.destinationStart = startDestination
        workerComponent.destinationEnd = endDestination
        let velocityX = 90.0 + Double(engine.appStateComponent.level) * 5.0 + randomness.nextDouble(from: 0.0, through: 10.0)
        let alienEntity = Entity(named: "\(EntityName.alienWorker)_\(totalAliens)")
        alienEntity
                .add(component: workerComponent)
                .add(component: AlienWorkerComponent())
                .add(component: VelocityComponent(velocityX: velocityX, velocityY: 0, wraps: false, base: velocityX))
                .add(component: PositionComponent(x: workerComponent.destinationStart.x,
                                                  y: workerComponent.destinationStart.y,
                                                  z: .asteroids))
                .add(component: GunComponent(offsetX: sprite.width / 2,
                                             offsetY: 0,
                                             minimumShotInterval: 1.25,
                                             torpedoLifetime: 0.75,
                                             torpedoColor: .white,
                                             ownerType: .computerOpponent,
                                             ownerEntity: alienEntity,
                                             numTorpedoes: Int.max))
                .add(component: AlienFiringComponent.shared)
                .add(component: CollidableComponent(radius: 25))
                .add(component: DisplayComponent(sknode: sprite))
                .add(component: ReactionTimeComponent(reactionTime: 0.5)) //TODO: Adjust based on level or wave
        sprite.entity = alienEntity
        try? engine.add(entity: alienEntity)
    }

    func createAlienSoldier(startDestination: CGPoint, endDestination: CGPoint) {
        guard engine.findEntity(named: .player) != nil else { return }
        totalAliens += 1
        let sprite = SwashScaledSpriteNode(imageNamed: .alienSoldier)
        sprite.name = "\(EntityName.alienSoldier)_\(totalAliens)"
//        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
//        sprite.physicsBody?.isDynamic = true
//        sprite.physicsBody?.affectedByGravity = false
//        sprite.physicsBody?.categoryBitMask = alienCategory
//        sprite.physicsBody?.contactTestBitMask = asteroidCategory | playerCategory | torpedoCategory
        let soldierComponent = AlienComponent(cast: .soldier,
                                              reactionTime: randomness.nextDouble(from: 0.4, through: 0.8),
                                              scoreValue: 350)
        soldierComponent.destinationStart = startDestination
        soldierComponent.destinationEnd = endDestination
        let velocityX = 120.0 + Double(engine.appStateComponent.level) * 5.0 + randomness.nextDouble(from: 0.0, through: 10.0)
        let alienEntity = Entity(named: "\(EntityName.alienSoldier)_\(totalAliens)")
        alienEntity
                .add(component: soldierComponent)
                .add(component: AlienSoldierComponent())
                .add(component: VelocityComponent(velocityX: velocityX, velocityY: 0, wraps: false, base: velocityX))
                .add(component: PositionComponent(x: soldierComponent.destinationStart.x,
                                                  y: soldierComponent.destinationStart.y,
                                                  z: .asteroids))
                .add(component: GunComponent(offsetX: sprite.width / 2,
                                             offsetY: 0,
                                             minimumShotInterval: 1.25,
                                             torpedoLifetime: 0.75,
                                             torpedoColor: .white,
                                             ownerType: .computerOpponent,
                                             ownerEntity: alienEntity,
                                             numTorpedoes: Int.max))
                .add(component: AlienFiringComponent.shared)
                .add(component: CollidableComponent(radius: 25))
                .add(component: DisplayComponent(sknode: sprite))
                .add(component: ShootableComponent.shared)
                .add(component: ReactionTimeComponent(reactionTime: 0.4)) //TODO: Adjust based on level or wave
        sprite.entity = alienEntity
        try? engine.add(entity: alienEntity)
    }
}
