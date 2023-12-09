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
	func createShip(_ state: AppStateComponent) {
		let ship = ShipEntity(name: .ship, state: state, input: inputComponent)
        do {
            try engine.addEntity(entity: ship)
        }
        catch SwashError.entityNameAlreadyInUse(let message) {
            fatalError(message)
        }
        catch {
            fatalError("Unexpected error: \(error).")
        }
	}
}

/// I prefer to keep Entities as simple as possible, but this is a special case since
/// the ship is the player’s avatar, it is the most important entity in the game.
class ShipEntity: Entity {
    init(name: String, state: AppStateComponent, input: InputComponent) {
        super.init(name: name)
        let shipSprite = SwashteroidsSpriteNode(texture: createShipTexture())
        shipSprite.name = name
        shipSprite.zPosition = Layer.ship.rawValue
        let nacellesSprite = SwashteroidsSpriteNode(texture: createNacelleTexture())
        nacellesSprite.zPosition = shipSprite.zPosition + 0.1
        nacellesSprite.isHidden = true
        nacellesSprite.name = "nacelles"
        shipSprite.addChild(nacellesSprite)
        shipSprite.entity = self
        let thrust = SKAction.playSoundFileNamed("thrust.wav", waitForCompletion: true)
        add(component: ShipComponent())
        //  add(component: GunComponent(offsetX: 21, offsetY: 0, minimumShotInterval: 0.25, bulletLifetime: 2))
        add(component: WarpDriveComponent())
        add(component: HyperSpaceEngineComponent())
        add(component: AudioComponent())
        add(component: RepeatingAudioComponent(thrust, withKey: "thrust"))
        add(component: PositionComponent(x: 512, y: 384, z: .ship, rotation: 0.0))
        add(component: ShipComponent())
        add(component: MotionComponent(velocityX: 0.0, velocityY: 0.0, damping: 0.0))
        add(component: CollisionComponent(radius: 25))
        add(component: DisplayComponent(sknode: shipSprite))
        add(component: MotionControlsComponent(left: 1, right: 2, accelerate: 4, accelerationRate: 90, rotationRate: 100))
        add(component: input)
        add(component: AccelerometerComponent())
        add(component: ChangeShipControlsStateComponent(to: state.shipControlsState))
        switch state.shipControlsState {
            case .hidingButtons:
                add(component: AccelerometerComponent())
            case .showingButtons:
                remove(componentClass: AccelerometerComponent.self)
        }
    }

    // MARK: - Convenience accessors
    var warpDrive: WarpDriveComponent? {
        get { self[WarpDriveComponent.name] as? WarpDriveComponent }
    }
    var repeatingAudio: RepeatingAudioComponent? {
        get { self[RepeatingAudioComponent.name] as? RepeatingAudioComponent }
    }
    var audio: AudioComponent? {
        get { self[AudioComponent.name] as? AudioComponent }
    }

	/// Since there is significant modification to the ship entity’s components, 
	/// plus visual and sound effects, I pulled them into the ShipEntity class.
	/// - Parameter audio: Technically, I do not need to pass this in since the ship entity has an audio component and
    /// this should be the same one. The reason I am passing it in is that I prefer Systems generally avoid
    /// knowing about or using Entities. Since the audio came from the system, this method is more like an extension 
    /// to the system calling it. 
    func destroy(with audio: AudioComponent) {
        // Sound effects
        audio.removeSoundAction("thrust")
        let bang = SKAction.playSoundFileNamed("bangLarge.wav", waitForCompletion: false)
        audio.addSoundAction(bang, withKey: "shipExplosion")
        // Visual effects
        let spriteNode = SwashteroidsSpriteNode(texture: createShipTexture(color: .red))
        let fade = SKAction.fadeOut(withDuration: 3.0)
        let emitter = SKEmitterNode(fileNamed: "shipExplosion.sks")!
        spriteNode.addChild(emitter)
        spriteNode.run(fade)
        // Remove components
        remove(componentClass: InputComponent.self)
        remove(componentClass: GunComponent.self)
        remove(componentClass: MotionControlsComponent.self)
        remove(componentClass: DisplayComponent.self)
        remove(componentClass: HyperSpaceEngineComponent.self)
        // Add components
        add(component: DisplayComponent(sknode: spriteNode))
        add(component: DeathThroesComponent(countdown: 3.0))
        add(component: AudioComponent())
    }
}
