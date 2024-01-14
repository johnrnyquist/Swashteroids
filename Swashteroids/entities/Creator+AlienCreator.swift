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
    func createAlien(scene: GameScene) {
        guard engine.findEntity(named: .player) != nil else { return }
        numAliens += 1
        let sprite = SwashSpriteNode(imageNamed: .alien)
        sprite.name = "\(EntityName.alien)_\(numAliens)"
//        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
//        sprite.physicsBody?.isDynamic = true
//        sprite.physicsBody?.affectedByGravity = false
//        sprite.physicsBody?.categoryBitMask = alienCategory
//        sprite.physicsBody?.contactTestBitMask = asteroidCategory | playerCategory | torpedoCategory
        let alienComponent = AlienComponent(reactionTime: Double.random(in: 0.4...0.8), killScore: 350)
        let left = CGPoint(x: -sprite.width * 3,
                           y: Double.random(in: 40...(size.height - 40)))
        let right = CGPoint(x: size.width + sprite.width * 3,
                            y: Double.random(in: 40...(size.height - 40)))
        let leftSide: Bool
        switch Bool.random() {
            case true:
                leftSide = true
                alienComponent.startDestination = left
                alienComponent.endDestination = right
            case false:
                leftSide = false
                alienComponent.startDestination = right
                alienComponent.endDestination = left
        }
        let velocityX = Double.random(in: -10.0...30.0) + 60.0
        let alien = Entity(named: "\(EntityName.alien)_\(numAliens)")
                .add(component: alienComponent)
                .add(component: CollidableComponent(radius: 25))
                .add(component: PositionComponent(x: alienComponent.startDestination.x,
                                                  y: alienComponent.startDestination.y,
                                                  z: .asteroids))
                .add(component: VelocityComponent(velocityX: velocityX, velocityY: 0, wraps: false, base: velocityX))
                .add(component: AudioComponent(fileNamed: .alienEntrance, actionKey: "alienEntrance"))
                .add(component: GunComponent(offsetX: 21,
                                             offsetY: 0,
                                             minimumShotInterval: 1.25,
                                             torpedoLifetime: 0.75,
                                             torpedoColor: .white,
                                             ownerType: .computerOpponent,
                                             numTorpedoes: Int.max))
                .add(component: AlienFireDownComponent.shared)
                .add(component: DisplayComponent(sknode: sprite))
        sprite.entity = alien
        try? engine.add(entity: alien)
        //HACK for immediate gratification
        let warningSprite = SKSpriteNode(color: .alienWarning,
                                         size: CGSize(width: scene.size.width * 0.1, height: scene.size.height))
        scene.addChild(warningSprite)
        warningSprite.anchorPoint = .zero
        warningSprite.zPosition = .bottom
        if leftSide {
            warningSprite.x = 0
        } else {
            warningSprite.x = scene.size.width - warningSprite.width
        }
        let turnRed = SKAction.customAction(withDuration: 0.1) { _, _ in
            warningSprite.color = .alienWarning
        }
        let turnBlack = SKAction.customAction(withDuration: 0.1) { _, _ in
            warningSprite.color = .background
        }
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([turnRed, turnBlack, turnRed, turnBlack, turnRed, turnBlack, remove])
        warningSprite.run(sequence)
    }
}
