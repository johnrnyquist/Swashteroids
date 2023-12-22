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
    func createPlasmaTorpedo(_ gunComponent: GunComponent, _ parentPosition: PositionComponent, _ parentMotion: MotionComponent) {
        let cos = cos(parentPosition.rotation * Double.pi / 180)
        let sin = sin(parentPosition.rotation * Double.pi / 180)
        let sprite = SwashSpriteNode(texture: createTorpedoTexture(color: .plasmaTorpedo))
        let sparkEmitter = SKEmitterNode(fileNamed: "plasmaTorpedo.sks")!
        sparkEmitter.emissionAngle = parentPosition.rotation * Double.pi / 180 + Double.pi
        sprite.addChild(sparkEmitter)
        let name = "torpedo_\(numTorpedoes)"
        numTorpedoes += 1
        let entity = Entity(name: name)
                .add(component: PlasmaTorpedoComponent(lifeRemaining: gunComponent.torpedoLifetime))
                .add(component: PositionComponent(x: cos * gunComponent.offsetFromParent
                                                                       .x - sin * gunComponent.offsetFromParent
                                                                                              .y + parentPosition.position
                                                                                                                 .x,
                                                  y: sin * gunComponent.offsetFromParent
                                                                       .x + cos * gunComponent.offsetFromParent
                                                                                              .y + parentPosition.position
                                                                                                                 .y,
                                                  z: Layer.torpedoes,
                                                  rotation: 0))
                .add(component: CollisionComponent(radius: 0))
				.add(component: MotionComponent(velocityX: cos * 220 + parentMotion.velocity.x * 1.0/scaleManager.SCALE_FACTOR,
												velocityY: sin * 220 + parentMotion.velocity.y * 1.0/scaleManager.SCALE_FACTOR,
                                                angularVelocity: 0 + parentMotion.angularVelocity,
                                                dampening: 0 + parentMotion.dampening))
                .add(component: DisplayComponent(sknode: sprite))
                .add(component: AudioComponent(fileNamed: "fire.wav", actionKey: name))
        sprite.name = entity.name
        do {
            try engine.addEntity(entity: entity)
        } catch SwashError.entityNameAlreadyInUse(let message) {
            fatalError(message)
        } catch {
            fatalError("Unexpected error: \(error).")
        }
    }
}
