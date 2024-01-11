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

extension Creator: ShipCreator {
    func createShip(_ state: AppStateComponent) {
        let ship = Entity(named: .ship)
        let shipSprite = SwashSpriteNode(texture: createShipTexture())
        shipSprite.name = .ship
        shipSprite.zPosition = .ship
        let nacellesSprite = SKSpriteNode(texture: createNacelleTexture())
        nacellesSprite.zPosition = shipSprite.zPosition + 0.1 //HACK
        nacellesSprite.isHidden = true
        nacellesSprite.name = "nacelles"
        shipSprite.addChild(nacellesSprite)
        shipSprite.entity = ship
        ship.add(component: ShipComponent())
        ship.add(component: HyperspaceDriveComponent(jumps: 0))
        ship.add(component: GunComponent(offsetX: 21, offsetY: 0, minimumShotInterval: 0.25, torpedoLifetime: 2, ownerType: .player, ammo: 0))
        ship.add(component: WarpDriveComponent())
        ship.add(component: PositionComponent(x: state.gameSize.width / 2, y: state.gameSize.height / 2, z: .ship, rotationDegrees: 0.0))
        ship.add(component: VelocityComponent(velocityX: 0.0, velocityY: 0.0, dampening: 0.0, base: 60.0))
        ship.add(component: CollisionComponent(radius: 25))
        ship.add(component: DisplayComponent(sknode: shipSprite))
        ship.add(component: MovementRateComponent(accelerationRate: 90, rotationRate: 100))
        ship.add(component: InputComponent.shared)
        ship.add(component: AccelerometerComponent())
        ship.add(component: ChangeShipControlsStateComponent(to: state.shipControlsState))
        ship.add(component: RepeatingAudioComponent(sound: GameScene.sound)) //HACK
        switch state.shipControlsState {
            case .hidingButtons:
                ship.add(component: AccelerometerComponent())
            case .showingButtons:
                ship.remove(componentClass: AccelerometerComponent.self)
        }
        do {
            try engine.add(entity: ship)
        } catch SwashError.entityNameAlreadyInUse(let message) {
            fatalError(message)
        } catch {
            fatalError("Unexpected error: \(error).")
        }
    }

    /// Removes and adds components to the ship entity to put in a destroyed state.
    /// Also adds a flaming particle emitter to the ship sprite.
    func destroy(ship: Entity) {
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
        ship.remove(componentClass: GunComponent.self)
        ship.remove(componentClass: HyperspaceDriveComponent.self)
        ship.remove(componentClass: InputComponent.self)
        ship.remove(componentClass: MovementRateComponent.self)
        // Add components
        ship[VelocityComponent.self]?.angularVelocity = Double.random(in: -100.0...100.0)
        ship.add(component: DisplayComponent(sknode: spriteNode))
        ship.add(component: DeathThroesComponent(countdown: 3.0))
        ship.add(component: AudioComponent(fileNamed: .explosion, actionKey: "shipExplosion"))
    }
}
