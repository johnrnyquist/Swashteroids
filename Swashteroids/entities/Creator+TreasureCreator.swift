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
        let r = randomness.nextInt(from: 1, through: 5) == 5
        let standard = (color: UIColor.systemGreen, value: treasure_standard_value)
        let special = (color: UIColor.systemPink, value: treasure_special_value)
        let treasureData = r ? special : standard
        let sprite = SwashScaledSpriteNode(color: treasureData.color, size: CGSize(width: 12, height: 12))
        addEmitter(colored: treasureData.color, on: sprite)
        numTreasures += 1
        let treasureEntity = Entity(named: "treasure" + "_\(numTreasures)")
                .add(component: TreasureComponent(value: treasureData.value))
                .add(component: PositionComponent(x: positionComponent.x,
                                                  y: positionComponent.y,
                                                  z: .asteroids,
                                                  rotationDegrees: 45))
                .add(component: VelocityComponent(velocityX: 0, velocityY: 0, angularVelocity: 25, wraps: true, base: 0))
                .add(component: CollidableComponent(radius: 10))
                .add(component: DisplayComponent(sknode: sprite))
        sprite.entity = treasureEntity
        sprite.name = treasureEntity.name
        engine.replace(entity: treasureEntity)
    }
}
