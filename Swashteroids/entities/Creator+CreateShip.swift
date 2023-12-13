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
        let ship = ShipEntity(name: .ship, state: state)
        do {
            try engine.addEntity(entity: ship)
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
    init(name: String, state: AppStateComponent) {
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
        add(component: ShipComponent())
        add(component: WarpDriveComponent())
        add(component: PositionComponent(x: state.size.width/2, y: state.size.height/2, z: .ship, rotation: 0.0))
        add(component: ShipComponent())
        add(component: MotionComponent(velocityX: 0.0, velocityY: 0.0, damping: 0.0))
        add(component: CollisionComponent(radius: 25))
        add(component: DisplayComponent(sknode: shipSprite))
        add(component: MotionControlsComponent(left: 1, right: 2, accelerate: 4, accelerationRate: 90, rotationRate: 100))
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

    // MARK: - Convenience accessors
    var warpDrive: WarpDriveComponent? {
        self[WarpDriveComponent.name] as? WarpDriveComponent
    }
    var repeatingAudio: RepeatingAudioComponent? {
        self[RepeatingAudioComponent.name] as? RepeatingAudioComponent
    }
    var audio: AudioComponent? {
        self[AudioComponent.name] as? AudioComponent
    }

    /// Removes and adds components to the ship entity to put in a destroyed state.
    /// Also adds a flaming particle emitter to the ship sprite.
    func destroy() {
        // Visual effects
        let spriteNode = SwashteroidsSpriteNode(texture: createShipTexture(color: .red))
        let fade = SKAction.fadeOut(withDuration: 3.0)
        let emitter = SKEmitterNode(fileNamed: "shipExplosion.sks")!
        spriteNode.addChild(emitter)
        spriteNode.run(fade)
        repeatingAudio?.state = .shouldStop
        // Remove components
        remove(componentClass: AudioComponent.self)
        remove(componentClass: DisplayComponent.self)
        remove(componentClass: GunComponent.self)
        remove(componentClass: HyperSpaceEngineComponent.self)
        remove(componentClass: InputComponent.self)
        remove(componentClass: MotionControlsComponent.self)
        // Add components
        add(component: DisplayComponent(sknode: spriteNode))
        add(component: DeathThroesComponent(countdown: 3.0))
        add(component: AudioComponent(fileNamed: "bangLarge.wav", actionKey: "shipExplosion"))
    }
}
