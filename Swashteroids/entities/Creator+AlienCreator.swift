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

extension Creator: AlienCreator {
    func createAliens(scene: GameScene) {
        guard engine.findEntity(named: .player) != nil else { return }
        let entrance = pickEntrance()
        warningAliens(scene: scene, leftSide: entrance.leftSide)
        switch engine.appStateComponent.level {
            case 1:
                createAlienWorker(scene: scene,
                                  startDestination: CGPoint(x: entrance.startDestination.x, y: entrance.startDestination.y + 50),
                                  endDestination: entrance.endDestination)
            case 2:
                switch randomness.nextBool() {
                    case true:
                        createTwoWorkers(scene: scene, entrance: entrance)
                    case false:
                        createAlienWorker(scene: scene,
                                          startDestination: CGPoint(x: entrance.startDestination.x,
                                                                    y: entrance.startDestination.y + 50),
                                          endDestination: entrance.endDestination)
                }
            case 3:
                switch randomness.nextInt(from: 1, through: 3) {
                    case 1:
                        createTwoWorkers(scene: scene, entrance: entrance)
                    case 2:
                        createSoldier(scene: scene, entrance: entrance)
                    case 3:
                        createAlienWorker(scene: scene,
                                          startDestination: CGPoint(x: entrance.startDestination.x,
                                                                    y: entrance.startDestination.y + 50),
                                          endDestination: entrance.endDestination)
                    default:
                        break
                }
            default:
                switch randomness.nextInt(from: 1, through: 5) {
                    case 1:
                        createTwoWorkers(scene: scene, entrance: entrance)
                    case 2:
                        createAlienWorker(scene: scene,
                                          startDestination: CGPoint(x: entrance.startDestination.x,
                                                                    y: entrance.startDestination.y + 50),
                                          endDestination: entrance.endDestination)
                    case 3:
                        createSoldier(scene: scene, entrance: entrance)
                    case 4:
                        createAlienWorker(scene: scene,
                                          startDestination: CGPoint(x: entrance.startDestination.x,
                                                                    y: entrance.startDestination.y + 50),
                                          endDestination: entrance.endDestination)
                        createSoldier(scene: scene, entrance: entrance)
                    case 5:
                        createTwoWorkers(scene: scene, entrance: entrance)
                        createSoldier(scene: scene, entrance: entrance)
                    default:
                        break
                }
        }
        engine.appStateEntity.add(component: AudioComponent(fileNamed: .alienEntrance, actionKey: "alienEntrance"))
    }

    func createSoldier(scene: GameScene, entrance: (startDestination: CGPoint, endDestination: CGPoint, leftSide: Bool)) {
        createAlienSoldier(scene: scene,
                           startDestination: entrance.startDestination,
                           endDestination: entrance.endDestination)
    }

    func createTwoWorkers(scene: GameScene, entrance: (startDestination: CGPoint, endDestination: CGPoint, leftSide: Bool)) {
        createAlienWorker(scene: scene,
                          startDestination: CGPoint(x: entrance.startDestination.x, y: entrance.startDestination.y + 50),
                          endDestination: entrance.endDestination)
        createAlienWorker(scene: scene,
                          startDestination: CGPoint(x: entrance.startDestination.x, y: entrance.startDestination.y - 50),
                          endDestination: entrance.endDestination)
    }

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

    func createAlienWorker(scene: GameScene, startDestination: CGPoint, endDestination: CGPoint) {
        guard engine.findEntity(named: .player) != nil else { return }
        print(self, #function)
        numAliens += 1
        let sprite = SwashScaledSpriteNode(imageNamed: .alienWorker)
        sprite.name = "\(EntityName.alienWorker)_\(numAliens)"
//        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
//        sprite.physicsBody?.isDynamic = true
//        sprite.physicsBody?.affectedByGravity = false
//        sprite.physicsBody?.categoryBitMask = alienCategory
//        sprite.physicsBody?.contactTestBitMask = asteroidCategory | playerCategory | torpedoCategory
        let workerComponent = AlienComponent(reactionTime: randomness.nextDouble(from: 0.4, through: 0.8), killScore: 50)
        workerComponent.startDestination = startDestination
        workerComponent.endDestination = endDestination
        let velocityX = 90.0 + Double(engine.appStateComponent.level) * 5.0 + randomness.nextDouble(from: 0.0, through: 10.0)
        let alienEntity = Entity(named: "\(EntityName.alienWorker)_\(numAliens)")
        alienEntity
                .add(component: workerComponent)
                .add(component: AlienWorkerComponent())
                .add(component: VelocityComponent(velocityX: velocityX, velocityY: 0, wraps: false, base: velocityX))
                .add(component: PositionComponent(x: workerComponent.startDestination.x,
                                                  y: workerComponent.startDestination.y,
                                                  z: .asteroids))
                .add(component: GunComponent(offsetX: sprite.width / 2,
                                             offsetY: 0,
                                             minimumShotInterval: 1.25,
                                             torpedoLifetime: 0.75,
                                             torpedoColor: .white,
                                             ownerType: .computerOpponent,
                                             ownerEntity: alienEntity,
                                             numTorpedoes: Int.max))
                .add(component: AlienFireDownComponent.shared)
                .add(component: CollidableComponent(radius: 25))
                .add(component: DisplayComponent(sknode: sprite))
        sprite.entity = alienEntity
        try? engine.add(entity: alienEntity)
    }

    func createAlienSoldier(scene: GameScene, startDestination: CGPoint, endDestination: CGPoint) {
        guard engine.findEntity(named: .player) != nil else { return }
        print(self, #function)
        numAliens += 1
        let sprite = SwashScaledSpriteNode(imageNamed: .alienSoldier)
        sprite.name = "\(EntityName.alienSoldier)_\(numAliens)"
//        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
//        sprite.physicsBody?.isDynamic = true
//        sprite.physicsBody?.affectedByGravity = false
//        sprite.physicsBody?.categoryBitMask = alienCategory
//        sprite.physicsBody?.contactTestBitMask = asteroidCategory | playerCategory | torpedoCategory
        let soldierComponent = AlienComponent(reactionTime: randomness.nextDouble(from: 0.4, through: 0.8), killScore: 350)
        soldierComponent.startDestination = startDestination
        soldierComponent.endDestination = endDestination
        let velocityX = 120.0 + Double(engine.appStateComponent.level) * 5.0 + randomness.nextDouble(from: 0.0, through: 10.0)
        let alienEntity = Entity(named: "\(EntityName.alienSoldier)_\(numAliens)")
        alienEntity
                .add(component: soldierComponent)
                .add(component: AlienSoldierComponent())
                .add(component: VelocityComponent(velocityX: velocityX, velocityY: 0, wraps: false, base: velocityX))
                .add(component: PositionComponent(x: soldierComponent.startDestination.x,
                                                  y: soldierComponent.startDestination.y,
                                                  z: .asteroids))
                .add(component: GunComponent(offsetX: sprite.width / 2,
                                             offsetY: 0,
                                             minimumShotInterval: 1.25,
                                             torpedoLifetime: 0.75,
                                             torpedoColor: .white,
                                             ownerType: .computerOpponent,
                                             ownerEntity: alienEntity,
                                             numTorpedoes: Int.max))
                .add(component: AlienFireDownComponent.shared)
                .add(component: CollidableComponent(radius: 25))
                .add(component: DisplayComponent(sknode: sprite))
        sprite.entity = alienEntity
        try? engine.add(entity: alienEntity)
    }
}
