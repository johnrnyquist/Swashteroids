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

protocol ShipCreator: AnyObject {
    func createShip(_ state: AppStateComponent)
}

extension Creator: ShipCreator {
    func createShip(_ state: AppStateComponent) {
        let ship = ShipEntity(name: .ship, state: state)
        do {
            try engine.add(entity: ship)
        } catch SwashError.entityNameAlreadyInUse(let message) {
            fatalError(message)
        } catch {
            fatalError("Unexpected error: \(error).")
        }
    }
}

/// I prefer to keep Entities as simple as possible, but this is a special case since
/// the ship is the player’s avatar, it is the most important entity in the game.
class ShipEntity: Entity {
    // MARK: - Convenience accessors, my main reason for making an Entity subclass
    var warpDrive: WarpDriveComponent? {
        self[WarpDriveComponent.name] as? WarpDriveComponent
    }
    var repeatingAudio: RepeatingAudioComponent? {
        self[RepeatingAudioComponent.name] as? RepeatingAudioComponent
    }
    var audio: AudioComponent? {
        self[AudioComponent.name] as? AudioComponent
    }

    init(name: String, state: AppStateComponent) {
        super.init(named: name)
        let shipSprite = SwashSpriteNode(texture: createShipTexture())
        shipSprite.name = name
        shipSprite.zPosition = .ship
        let nacellesSprite = SKSpriteNode(texture: createNacelleTexture())
        nacellesSprite.zPosition = shipSprite.zPosition + 0.1 //HACK
        nacellesSprite.isHidden = true
        nacellesSprite.name = "nacelles"
        shipSprite.addChild(nacellesSprite)
        shipSprite.entity = self
        add(component: ShipComponent())
        add(component: WarpDriveComponent())
        add(component: PositionComponent(x: state.size.width / 2, y: state.size.height / 2, z: .ship, rotationDegrees: 0.0))
        add(component: VelocityComponent(velocityX: 0.0, velocityY: 0.0, dampening: 0.0))
        add(component: CollisionComponent(radius: 25))
        add(component: DisplayComponent(sknode: shipSprite))
        add(component: MovementRateComponent(accelerationRate: 90, rotationRate: 100))
        add(component: InputComponent.shared)
        add(component: AccelerometerComponent())
        add(component: ChangeShipControlsStateComponent(to: state.shipControlsState))
        add(component: RepeatingAudioComponent(sound: GameScene.sound)) //HACK
        switch state.shipControlsState {
            case .hidingButtons:
                add(component: AccelerometerComponent())
            case .showingButtons:
                remove(componentClass: AccelerometerComponent.self)
        }
    }

    /// Removes and adds components to the ship entity to put in a destroyed state.
    /// Also adds a flaming particle emitter to the ship sprite.
    func destroy() {
        // Visual effects
        let spriteNode = SwashSpriteNode(texture: createShipTexture(color: .red))
        let fade = SKAction.fadeOut(withDuration: 3.0)
        let emitter = SKEmitterNode(fileNamed: "shipExplosion.sks")!
        spriteNode.addChild(emitter)
        spriteNode.run(fade)
        repeatingAudio?.state = .shouldStop
        // Remove components
        remove(componentClass: AudioComponent.self)
        remove(componentClass: DisplayComponent.self)
        remove(componentClass: GunComponent.self)
        remove(componentClass: HyperspaceEngineComponent.self)
        remove(componentClass: InputComponent.self)
        remove(componentClass: MovementRateComponent.self)
        // Add components
        add(component: DisplayComponent(sknode: spriteNode))
        add(component: DeathThroesComponent(countdown: 3.0))
        add(component: AudioComponent(fileNamed: "bangLarge.wav", actionKey: "shipExplosion"))
    }
}
