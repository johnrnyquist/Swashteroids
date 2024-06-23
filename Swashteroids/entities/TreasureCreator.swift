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

class TreasureCreator: TreasureCreatorUseCase {
    private var totalTreasures = 0
    private weak var engine: Engine!
    private weak var randomness: Randomizing!

    init(engine: Engine, randomness: Randomizing = Randomness.shared) {
        self.engine = engine
        self.randomness = randomness
    }

    func createTreasure(positionComponent: PositionComponent) {
        let treasureIsSpecial = randomness.nextInt(from: 1, through: 5) == 5
        let standard = (color: UIColor.systemGreen, value: treasure_standard_value)
        let special = (color: UIColor.systemPink, value: treasure_special_value)
        let treasureData = treasureIsSpecial ? special : standard
        let sprite = SwashScaledSpriteNode(color: treasureData.color, size: CGSize(width: 12, height: 12))
        addEmitter(colored: treasureData.color, on: sprite)
        totalTreasures += 1
        let treasureEntity = Entity(named: "treasure" + "_\(totalTreasures)")
                .add(component: TreasureComponent(value: treasureData.value))
                .add(component: PositionComponent(x: positionComponent.x,
                                                  y: positionComponent.y,
                                                  z: .asteroids,
                                                  rotationDegrees: 45))
                .add(component: VelocityComponent(velocityX: 0, velocityY: 0, angularVelocity: 25, wraps: true, base: 0))
                .add(component: CollidableComponent(radius: 10))
                .add(component: DisplayComponent(sknode: sprite))
                .add(component: AlienWorkerTargetComponent.shared)
                .add(component: LifetimeComponent(timeRemaining: 30))
        sprite.entity = treasureEntity
        sprite.name = treasureEntity.name
        engine.replace(entity: treasureEntity)
    }

    func addEmitter(colored color: UIColor, on sknode: SKNode) {
        if let emitter = SKEmitterNode(fileNamed: "fireflies_mod.sks") {
            // emitter.setScale(1.0 * scaleManager.SCALE_FACTOR)
            // let colorRamp: [UIColor] = [color.lighter(by: 30.0).shiftHue(by: 10.0)]
            let colorRamp: [UIColor] = [color.shiftHue(by: 5.0)]
            let keyTimes: [NSNumber] = [1.0]
            let colorSequence = SKKeyframeSequence(keyframeValues: colorRamp, times: keyTimes)
            emitter.particleColorSequence = colorSequence
            sknode.addChild(emitter)
        }
    }
}
