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

protocol TorpedoCreator: AnyObject {
    func createPlasmaTorpedo(_ gunComponent: GunComponent, _ position: PositionComponent, _ velocity: VelocityComponent)
}

extension Creator: TorpedoCreator {
    func createPlasmaTorpedo(_ gunComponent: GunComponent, _ position: PositionComponent, _ velocity: VelocityComponent) {
        let cos = cos(position.rotationRadians)
        let sin = sin(position.rotationRadians)
        let sprite = SwashSpriteNode(texture: createTorpedoTexture(color: .torpedo))
        let sparkEmitter = SKEmitterNode(fileNamed: "plasmaTorpedo.sks")!
        sparkEmitter.emissionAngle = position.rotationRadians + Double.pi
        sprite.addChild(sparkEmitter)
        let name = "torpedo_\(numTorpedoes)"
        numTorpedoes += 1
        let entity = Entity(named: name)
                .add(component: PlasmaTorpedoComponent(lifeRemaining: gunComponent.torpedoLifetime))
                .add(component: PositionComponent(
                    x: cos * gunComponent.offsetFromParent.x - sin * gunComponent.offsetFromParent.y + position.x,
                    y: sin * gunComponent.offsetFromParent.x + cos * gunComponent.offsetFromParent.y + position.y,
                    z: Layer.torpedoes,
                    rotationDegrees: 0))
                .add(component: CollisionComponent(radius: 0))
                .add(component: VelocityComponent(
                    velocityX: cos * 220 + velocity.linearVelocity.x * 1.0 / scaleManager.SCALE_FACTOR,
                    velocityY: sin * 220 + velocity.linearVelocity.y * 1.0 / scaleManager.SCALE_FACTOR,
                    angularVelocity: 0 + velocity.angularVelocity,
                    dampening: 0 + velocity.dampening))
                .add(component: DisplayComponent(sknode: sprite))
                .add(component: AudioComponent(fileNamed: "fire.wav", actionKey: name))
        sprite.name = entity.name
        do {
            try engine.add(entity: entity)
        } catch SwashError.entityNameAlreadyInUse(let message) {
            fatalError(message)
        } catch {
            fatalError("Unexpected error: \(error).")
        }
    }
}
