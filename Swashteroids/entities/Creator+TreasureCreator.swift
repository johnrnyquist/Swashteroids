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

extension Creator: TreasureCreator {
    func createTreasure(positionComponent: PositionComponent) {
        let r = Int.random(in: 1...5) == 5
        let standard = (color: UIColor.systemGreen, value: treasure_standard_value)
        let special = (color: UIColor.systemPink, value: treasure_special_value)
        let treasureData = r ? special : standard
        let sprite = SwashSpriteNode(color: treasureData.color, size: CGSize(width: 12, height: 12))
        addEmitter(colored: treasureData.color, on: sprite)
        let treasureEntity = Entity(named: "treasure" + "_\(Int.random(in: 0...10_000))")
                .add(component: TreasureComponent(value: treasureData.value))
                .add(component: PositionComponent(x: positionComponent.x,
                                                  y: positionComponent.y,
                                                  z: .asteroids,
                                                  rotationDegrees: 45))
                .add(component: VelocityComponent(velocityX: 0, velocityY: 0, angularVelocity: 25, wraps: true, base: 0))
                .add(component: CollidableComponent(radius: 10))
                .add(component: DisplayComponent(sknode: sprite))
        sprite.entity = treasureEntity
        engine.replace(entity: treasureEntity)
    }
}