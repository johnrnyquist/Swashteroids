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

extension Creator: ShipCreatorUseCase {
    func createShip(_ state: AppStateComponent) {
        let player = Entity(named: .player)
        let sprite = SwashScaledSpriteNode(texture: createShipTexture())
//        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size.scaled(by: 0.8))//(circleOfRadius: 25 * scaleManager.SCALE_FACTOR)
//        sprite.physicsBody?.isDynamic = true
//        sprite.physicsBody?.affectedByGravity = false
//        sprite.physicsBody?.categoryBitMask = playerCategory
//        sprite.physicsBody?.contactTestBitMask = asteroidCategory | alienCategory | torpedoCategory
//        sprite.physicsBody?.collisionBitMask = 0
        sprite.name = .player
        sprite.zPosition = .ship
        let nacellesSprite = SKSpriteNode(texture: createNacelleTexture())
        nacellesSprite.zPosition = sprite.zPosition + 0.1 //HACK
        nacellesSprite.isHidden = true
        nacellesSprite.name = "nacelles"
        sprite.addChild(nacellesSprite)
        sprite.entity = player
        player.add(component: ShipComponent())
        player.add(component: HyperspaceDriveComponent(jumps: 0))
        player.add(component: GunComponent(offsetX: sprite.width / 2,
                                           offsetY: 0,
                                           minimumShotInterval: 0.1,
                                           torpedoLifetime: 2,
                                           ownerType: .player,
                                           ownerEntity: player,
                                           numTorpedoes: 0))
        player.add(component: WarpDriveComponent())
        player.add(component: PositionComponent(x: state.gameSize.width / 2,
                                                y: state.gameSize.height / 2,
                                                z: .ship,
                                                rotationDegrees: 0.0))
        player.add(component: VelocityComponent(velocityX: 0.0, velocityY: 0.0, dampening: 0.0, base: 60.0))
        player.add(component: CollidableComponent(radius: 25))
        player.add(component: DisplayComponent(sknode: sprite))
        player.add(component: MovementRateComponent(accelerationRate: 90, rotationRate: 100))
        player.add(component: InputComponent.shared)
        player.add(component: AccelerometerComponent())
        player.add(component: ChangeShipControlsStateComponent(to: state.shipControlsState))
        player.add(component: RepeatingAudioComponent(sound: GameScene.sound)) //HACK
        switch state.shipControlsState {
            case .hidingButtons:
                player.add(component: AccelerometerComponent())
            case .showingButtons:
                player.remove(componentClass: AccelerometerComponent.self)
            case .usingScreenControls:
                break
            case .usingGameController:
                break
        }
        do {
            try engine.add(entity: player)
        } catch SwashError.entityNameAlreadyInUse(let message) {
            fatalError(message)
        } catch {
            fatalError("Unexpected error: \(error).")
        }
    }


    /// Removes and adds components to the ship entity to put in a destroyed state.
    /// Also adds a flaming particle emitter to the ship sprite.
    func destroy(ship: Entity) {
        if ship.has(componentClassName: ShipComponent.name) == true {
            screenFlashRed()
        }
        // Visual effects
        let spriteNode = ship[DisplayComponent.self]!.sprite! //HACK
        spriteNode.color = .red
        spriteNode.colorBlendFactor = 1.0
        let fade = SKAction.fadeOut(withDuration: 3.0)
        let emitter = SKEmitterNode(fileNamed: "shipExplosion.sks")!
        spriteNode.addChild(emitter)
        spriteNode.run(fade)
        ship[RepeatingAudioComponent.self]?.state = .shouldStop
        // Remove components
        ship.remove(componentClass: AudioComponent.self)
        ship.remove(componentClass: DisplayComponent.self)
        ship.remove(componentClass: CollidableComponent.self)
        ship.remove(componentClass: GunComponent.self)
        ship.remove(componentClass: HyperspaceDriveComponent.self)
        ship.remove(componentClass: InputComponent.self)
        ship.remove(componentClass: MovementRateComponent.self)
        // Add components
        ship[VelocityComponent.self]?.angularVelocity = randomness.nextDouble(from: -100.0, through: 100.0)
        ship.add(component: DisplayComponent(sknode: spriteNode))
        ship.add(component: DeathThroesComponent(countdown: 3.0))
        ship.add(component: AudioComponent(fileNamed: .explosion, actionKey: "shipExplosion"))
    }

    func screenFlashRed() {
        let entity = Entity(named: "screenFlash")
        engine.replace(entity: entity)
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
