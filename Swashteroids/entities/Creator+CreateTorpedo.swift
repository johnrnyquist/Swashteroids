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
        let sprite = SwashteroidsSpriteNode(texture: createBulletTexture(color: .plasmaTorpedo))
        let sparkEmitter = SKEmitterNode(fileNamed: "plasmaTorpedo.sks")!
        sparkEmitter.emissionAngle = parentPosition.rotation * Double.pi / 180 + Double.pi
        sprite.addChild(sparkEmitter)
        let name = "bullet_\(numTorpedoes)"
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
                                                  z: Layer.bullets,
                                                  rotation: 0))
                .add(component: CollisionComponent(radius: 0))
                .add(component: MotionComponent(velocityX: cos * 220 + parentMotion.velocity.x,
                                                velocityY: sin * 220 + parentMotion.velocity.y,
                                                angularVelocity: 0 + parentMotion.angularVelocity,
                                                damping: 0 + parentMotion.damping))
                .add(component: DisplayComponent(sknode: sprite))
        .add(component: AudioComponent(fileNamed: "fire.wav", withKey: name))
        sprite.name = entity.name
        engine.replaceEntity(entity: entity)
    }
}