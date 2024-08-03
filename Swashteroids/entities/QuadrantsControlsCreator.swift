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

enum QuadrantAction {
    case thrust
    case hyperspace
    case flip
    case fire
}

final class QuadrantsControlsCreator: QuadrantsControlsCreatorUseCase {
    private var engine: Engine
    private var size: CGSize

    init(engine: Engine, size: CGSize) {
        self.engine = engine
        self.size = size
    }

    func removeQuadrantControls() {
        let quadrants: [EntityName] = [.q1, .q2, .q3, .q4]
        engine.removeEntities(named: quadrants)
    }

    func createQuadrantSprite(quadrant: QuadrantAction, entity: Entity) -> SwashSpriteNode {
        let quadrantSprite = SwashSpriteNode(color: .black, size: CGSize(width: size.halfWidth, height: size.halfHeight))
        quadrantSprite.alpha = 0.0
        let background = SwashSpriteNode(color: .white, size: CGSize(width: size.halfWidth - 6, height: size.halfHeight - 6))
        background.position = CGPoint(x: 3, y: 3)
        background.alpha = 0.3
        background.anchorPoint = .zero
        quadrantSprite.addChild(background)
        let position: CGPoint
        let sprite: SwashSpriteNode
        switch quadrant {
            case .hyperspace:
                position = CGPoint(x: 0, y: size.halfHeight)
                sprite = SwashSpriteNode(imageNamed: .hyperspaceButton)
            case .flip:
                position = CGPoint(x: size.halfWidth, y: size.halfHeight)
                sprite = SwashSpriteNode(imageNamed: .flipButton)
            case .thrust:
                position = CGPoint(x: 0, y: 0)
                sprite = SwashSpriteNode(imageNamed: .thrustButton)
            case .fire:
                position = CGPoint(x: size.halfWidth, y: 0)
                sprite = SwashSpriteNode(imageNamed: .fireButton)
        }
        sprite.position = CGPoint(x: size.halfWidth / 2, y: size.halfHeight / 2)
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        background.addChild(sprite)
        quadrantSprite.anchorPoint = CGPoint(x: 0, y: 0)
        quadrantSprite.position = position
        quadrantSprite.swashEntity = entity
        return quadrantSprite
    }

    /// Instead of visible buttons, the player will be able to touch quadrants on the screen to control the ship.
    func createQuadrantControls() {
        // Create the entities
        let q1Entity = Entity(named: .q1)
        let q2Entity = Entity(named: .q2)
        let q3Entity = Entity(named: .q3)
        let q4Entity = Entity(named: .q4)
        // Create the sprites, with associated entities
        let q1Sprite = createQuadrantSprite(quadrant: .fire, entity: q1Entity)
        let q2Sprite = createQuadrantSprite(quadrant: .flip, entity: q2Entity)
        let q3Sprite = createQuadrantSprite(quadrant: .thrust, entity: q3Entity)
        let q4Sprite = createQuadrantSprite(quadrant: .hyperspace, entity: q4Entity)
        q1Sprite.name = .q1
        q2Sprite.name = .q2
        q3Sprite.name = .q3
        q4Sprite.name = .q4
        // Add the entities to the engine
        engine.add(entity: q1Entity)
        engine.add(entity: q2Entity)
        engine.add(entity: q3Entity)
        engine.add(entity: q4Entity)
        // Configure the entities
        q1Entity
                .add(component: DisplayComponent(sknode: q1Sprite))
                .add(component: PositionComponent(x: q1Sprite.x, y: q1Sprite.y, z: .bottom, rotationDegrees: 0))
                .add(component: TouchableComponent())
                .add(component: HapticFeedbackComponent.shared)
                .add(component: QuadrantComponent(quadrant: .q1))
                .flash(1, duration: 0.75, endAlpha: 0, wait: 2)
        q2Entity
                .add(component: DisplayComponent(sknode: q2Sprite))
                .add(component: PositionComponent(x: q2Sprite.x, y: q2Sprite.y, z: .bottom, rotationDegrees: 0))
                .add(component: TouchableComponent())
                .add(component: HapticFeedbackComponent.shared)
                .add(component: QuadrantComponent(quadrant: .q2))
                .flash(1, duration: 0.75, endAlpha: 0, wait: 2)
        q3Entity
                .add(component: DisplayComponent(sknode: q3Sprite))
                .add(component: PositionComponent(x: q3Sprite.x, y: q3Sprite.y, z: .bottom, rotationDegrees: 0))
                .add(component: TouchableComponent())
                .add(component: HapticFeedbackComponent.shared)
                .add(component: QuadrantComponent(quadrant: .q3))
                .flash(1, duration: 0.75, endAlpha: 0, wait: 2)
        q4Entity
                .add(component: DisplayComponent(sknode: q4Sprite))
                .add(component: PositionComponent(x: q4Sprite.x, y: q4Sprite.y, z: .bottom, rotationDegrees: 0))
                .add(component: TouchableComponent())
                .add(component: HapticFeedbackComponent.shared)
                .add(component: QuadrantComponent(quadrant: .q4))
                .flash(1, duration: 0.75, endAlpha: 0, wait: 2)
    }
}
