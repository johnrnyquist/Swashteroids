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
    func createShip(_ state: ShipControlsState) {
        let shipSprite = SwashteroidsSpriteNode(texture: createShipTexture())
        let ship = Entity()
        ship.name = "ship"
        shipSprite.name = ship.name
        shipSprite.zPosition = Layers.ship.rawValue
        let nacellesSprite = SwashteroidsSpriteNode(texture: createEngineTexture())
        nacellesSprite.zPosition = shipSprite.zPosition + 0.1
        nacellesSprite.isHidden = true
        nacellesSprite.name = "nacelles"
        shipSprite.addChild(nacellesSprite)
        let thrust = SKAction.playSoundFileNamed("thrust.wav", waitForCompletion: true)
        ship
            // Uncomment to be able to fire right away
            //  .add(component: GunComponent(offsetX: 21, offsetY: 0, minimumShotInterval: 0.25, bulletLifetime: 2))
                .add(component: WarpDriveComponent())
                .add(component: HyperSpaceEngineComponent())
                .add(component: AudioComponent())
                .add(component: RepeatingAudioComponent(thrust, withKey: "thrust"))
                .add(component: PositionComponent(x: 512, y: 384, z: .ship, rotation: 0.0))
                .add(component: ShipComponent())
                .add(component: MotionComponent(velocityX: 0.0, velocityY: 0.0, damping: 0.0))
                .add(component: CollisionComponent(radius: 25))
                .add(component: DisplayComponent(sknode: shipSprite))
                .add(component: MotionControlsComponent(left: 1,
                                                        right: 2,
                                                        accelerate: 4,
                                                        accelerationRate: 90,
                                                        rotationRate: 100))
                .add(component: inputComponent)
                .add(component: AccelerometerComponent())
        switch state {
            case .hidingButtons:
                ship.add(component: AccelerometerComponent())
            case .showingButtons:
                ship.remove(componentClass: AccelerometerComponent.self)
        }
        engine.replaceEntity(entity: ship)
    }
}