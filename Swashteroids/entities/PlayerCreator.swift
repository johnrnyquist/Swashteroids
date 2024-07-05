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

class PlayerCreator: PlayerCreatorUseCase {
    let engine: Engine
    let size: CGSize
    let randomness: Randomizing
    weak var generator: UIImpactFeedbackGenerator?

    init(engine: Engine,
         size: CGSize,
         generator: UIImpactFeedbackGenerator? = nil,
         randomness: Randomizing = Randomness.shared) {
        self.engine = engine
        self.size = size
        self.generator = generator
        self.randomness = randomness
    }

    func createShip(_ state: GameStateComponent) {
        let ship = Entity(named: .player)
        let sprite = SwashScaledSpriteNode(texture: createShipTexture())
        //        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size.scaled(by: 0.8))//(circleOfRadius: 25 * scaleManager.SCALE_FACTOR)
        //        sprite.physicsBody?.isDynamic = true
        //        sprite.physicsBody?.affectedByGravity = false
        //        sprite.physicsBody?.categoryBitMask = playerCategory
        //        sprite.physicsBody?.contactTestBitMask = asteroidCategory | alienCategory | torpedoCategory
        //        sprite.physicsBody?.collisionBitMask = 0
        sprite.name = .player
        sprite.zPosition = .player
        let nacellesSprite = SKSpriteNode(texture: createNacelleTexture())
        nacellesSprite.zPosition = sprite.zPosition + 0.1 //HACK
        nacellesSprite.isHidden = true
        nacellesSprite.name = "nacelles"
        sprite.addChild(nacellesSprite)
        sprite.entity = ship
        ship
                .add(component: PlayerComponent())
                .add(component: HyperspaceDriveComponent(jumps: 0))
                .add(component: GunComponent(offsetX: sprite.width / 2,
                                             offsetY: 0,
                                             minimumShotInterval: 0.1,
                                             torpedoLifetime: 2,
                                             ownerType: .player,
                                             ownerName: ship.name,
                                             numTorpedoes: 0))
                .add(component: WarpDriveComponent())
                .add(component: PositionComponent(x: state.gameSize.width / 2,
                                                  y: state.gameSize.height / 2,
                                                  z: .player,
                                                  rotationDegrees: 0.0))
                .add(component: VelocityComponent(velocityX: 0.0, velocityY: 0.0, dampening: 0.0, base: 60.0))
                .add(component: CollidableComponent(radius: 25))
                .add(component: DisplayComponent(sknode: sprite))
                .add(component: MovementRateComponent(accelerationRate: 90, rotationRate: 100))
                .add(component: AccelerometerComponent.shared)
                .add(component: ChangeShipControlsStateComponent(to: state.shipControlsState))
                .add(component: RepeatingAudioComponent(name: "thrust", fileName: .thrust))
                .add(component: ShootableComponent.shared)
                .add(component: AlienWorkerTargetComponent.shared)
        switch state.shipControlsState {
        case .usingAccelerometer:
                ship.add(component: AccelerometerComponent.shared)
        case .usingScreenControls:
            ship.remove(componentClass: AccelerometerComponent.self)
            break
        case .usingGameController:
            ship.remove(componentClass: AccelerometerComponent.self)
            break
        }
        engine.add(entity: ship)
    }

    /// Removes and adds components to the ship entity to put in a destroyed state.
    /// Also adds a flaming particle emitter to the ship sprite.
    /// Used on both player and aliens right now.
    func destroy(entity: Entity) {
        if entity.has(componentClassName: PlayerComponent.name) == true {
            screenFlashRed()
        }
        // Visual effects
        let spriteNode = entity[DisplayComponent.self]!.sprite! //HACK
        spriteNode.color = .red
        spriteNode.colorBlendFactor = 1.0
        let fade = SKAction.fadeOut(withDuration: 3.0)
        let emitter = SKEmitterNode(fileNamed: "shipExplosion.sks")!
        spriteNode.addChild(emitter)
        spriteNode.run(fade)
        // Stop audio
        entity[RepeatingAudioComponent.self]?.state = .shouldStop
        // Remove components
        entity
                .remove(componentClass: AlienFiringComponent.self)
                .remove(componentClass: AudioComponent.self)
                .remove(componentClass: CollidableComponent.self)
                .remove(componentClass: DisplayComponent.self)
                .remove(componentClass: ExitScreenComponent.self)
                .remove(componentClass: GunComponent.self)
                .remove(componentClass: HyperspaceDriveComponent.self)
//                .remove(componentClass: InputComponent.self)
                .remove(componentClass: MoveToTargetComponent.self)
                .remove(componentClass: MovementRateComponent.self)
                .remove(componentClass: ReactionTimeComponent.self)
                .remove(componentClass: ShootableComponent.self)
        // Change components
        entity[VelocityComponent.self]?.angularVelocity = randomness.nextDouble(from: -100.0, through: 100.0)
        // Add components
        entity
                .add(component: DisplayComponent(sknode: spriteNode))
                .add(component: DeathThroesComponent(countdown: 3.0))
                .add(component: AudioComponent(name: "shipExplosion", fileName: .explosion))
    }

    func screenFlashRed() {
        let entity = Entity(named: "screenFlash")
        engine.add(entity: entity)
        // create a red sprite that covers the screen and has an alpha of 0.3
        let warningSprite = SKSpriteNode(color: .alienWarning, size: size)
        entity.add(component: DisplayComponent(sknode: warningSprite))
              .add(component: PositionComponent(x: 0, y: 0, z: .bottom))
        warningSprite.anchorPoint = .zero
        let turnRed = SKAction.customAction(withDuration: 0.1) { _, _ in
            self.generator?.impactOccurred()
            warningSprite.color = .alienWarning
            warningSprite.colorBlendFactor = 1.0
        }
        let turnBlack = SKAction.customAction(withDuration: 0.1) { _, _ in
            warningSprite.color = .background
            warningSprite.colorBlendFactor = 1.0
        }
        //
        let remove = SKAction.run {
            self.engine.remove(entity: entity)
        }
        let singleFlash = SKAction.sequence([turnRed, turnBlack])
        let flashing = SKAction.repeat(singleFlash, count: 4)
        let sequence = SKAction.sequence([flashing, remove])
        warningSprite.run(sequence)
    }
}

