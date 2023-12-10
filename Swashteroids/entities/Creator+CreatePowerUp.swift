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
    func createPlasmaTorpedoesPowerUp(radius: Double = 7, x: Double = 512, y: Double = 484, level: Int) {
        guard engine.getEntity(named: .plasmaTorpedoesPowerUp) == nil else { return }
        
        let r1 = Int.random(in: 75...(level * 130)) * [-1, 1].randomElement()!
        let r2 = Int.random(in: 75...(level * 100)) * [-1, 1].randomElement()!
        let centerX = min(Double(512 + r1), 1024)
        let centerY = min(Double(384 + r2), 768)
        let sprite = PlasmaTorpedoesPowerUpView(imageNamed: "scope")
        let emitter = SKEmitterNode(fileNamed: "plasmaTorpedoesPowerUp.sks")!
        sprite.addChild(emitter)
        let entity = Entity(name: .plasmaTorpedoesPowerUp)
        sprite.name = entity.name
        sprite.color = .plasmaTorpedo
        sprite.colorBlendFactor = 1.0
        entity
                .add(component: PositionComponent(x: centerX,
                                                  y: centerY,
                                                  z: .asteroids,
                                                  rotation: 0.0))
                .add(component: CollisionComponent(radius: radius))
                .add(component: GunPowerUpComponent())
                .add(component: DisplayComponent(sknode: sprite))
                .add(component: AnimationComponent(animation: sprite))
                .add(component: MotionComponent(velocityX: 0, velocityY: 0, angularVelocity: 100))
        engine.replaceEntity(entity: entity)
    }
}