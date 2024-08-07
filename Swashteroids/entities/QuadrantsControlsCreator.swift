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
        let quadrants: [EntityName] = [.fireQuadrant, .flipQuadrant, .thrustQuadrant, .hyperspaceQuadrant]
        engine.removeEntities(named: quadrants)
    }

    func createQuadrantSprite(quadrant: QuadrantAction, entity: Entity) -> SwashSpriteNode {
        // Create the quadrant sprite
        let quadrantSprite = SwashSpriteNode(color: .black, size: CGSize(width: size.halfWidth, height: size.halfHeight))
        quadrantSprite.alpha = 0.01
        quadrantSprite.anchorPoint = CGPoint(x: 0, y: 0)
        quadrantSprite.swashEntity = entity
        // Create the background
        let background = SwashSpriteNode(color: .white, size: CGSize(width: size.halfWidth - 6, height: size.halfHeight - 6))
        background.position = CGPoint(x: 3, y: 3)
        background.alpha = 0.2
        background.anchorPoint = .zero
        // Create the button image
        let buttonImageSprite: SwashSpriteNode
        switch quadrant {
            case .hyperspace:
                buttonImageSprite = SwashSpriteNode(imageNamed: ImageAsset.hyperspaceButton.name)
            case .flip:
                buttonImageSprite = SwashSpriteNode(imageNamed: ImageAsset.flipButton.name)
            case .thrust:
                buttonImageSprite = SwashSpriteNode(imageNamed: ImageAsset.thrustButton.name)
            case .fire:
                buttonImageSprite = SwashSpriteNode(imageNamed: ImageAsset.fireButton.name)
        }
        buttonImageSprite.position = CGPoint(x: quadrantSprite.size.halfWidth, y: quadrantSprite.size.halfHeight)
        buttonImageSprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        buttonImageSprite.alpha = 0.8
        // Add child nodes
        background.addChild(buttonImageSprite)
        quadrantSprite.addChild(background)
        return quadrantSprite
    }

    /// Instead of visible buttons, the player will be able to touch quadrants on the screen to control the ship.
    func createQuadrantControls() {
        let entityNames: [EntityName] = [.fireQuadrant, .flipQuadrant, .thrustQuadrant, .hyperspaceQuadrant]
        let entities = engine.entities.filter { entityNames.contains($0.name) }
        guard entities.isEmpty else { return }
        // Create the entities
        let fireEntity = Entity(named: .fireQuadrant)
        let flipEntity = Entity(named: .flipQuadrant)
        let thrustEntity = Entity(named: .thrustQuadrant)
        let hyperspaceEntity = Entity(named: .hyperspaceQuadrant)
        // Create the sprites
        let fireSprite = createQuadrantSprite(quadrant: .fire, entity: fireEntity)
        let flipSprite = createQuadrantSprite(quadrant: .flip, entity: flipEntity)
        let thrustSprite = createQuadrantSprite(quadrant: .thrust, entity: thrustEntity)
        let hyperspaceSprite = createQuadrantSprite(quadrant: .hyperspace, entity: hyperspaceEntity)
        // Set the names
        fireSprite.name = .fireQuadrant
        flipSprite.name = .flipQuadrant
        thrustSprite.name = .thrustQuadrant
        hyperspaceSprite.name = .hyperspaceQuadrant
        // Set the positions
        let lowerRight = CGPoint(x: size.halfWidth, y: 0)
        let upperRight = CGPoint(x: size.halfWidth, y: size.halfHeight)
        let lowerLeft = CGPoint(x: 0, y: 0)
        let upperLeft = CGPoint(x: 0, y: size.halfHeight)
        // Set flash arguments
        let numFlashes = 1
        let endAlpha = 0.01
        let duration = 1.2
        let wait = 0.0
        // Add the components
        fireEntity
                .add(component: DisplayComponent(sknode: fireSprite))
                .add(component: PositionComponent(point: lowerLeft, z: .bottom, rotationDegrees: 0))
                .add(component: TouchableComponent())
                .add(component: HapticFeedbackComponent.shared)
                .add(component: QuadrantComponent(quadrant: .fireQuadrant))
                .flash(numFlashes, duration: duration, endAlpha: endAlpha, wait: wait)
        flipEntity
                .add(component: DisplayComponent(sknode: flipSprite))
                .add(component: PositionComponent(point: upperLeft, z: .bottom, rotationDegrees: 0))
                .add(component: TouchableComponent())
                .add(component: HapticFeedbackComponent.shared)
                .add(component: QuadrantComponent(quadrant: .flipQuadrant))
                .flash(numFlashes, duration: duration, endAlpha: endAlpha, wait: wait)
        thrustEntity
                .add(component: DisplayComponent(sknode: thrustSprite))
                .add(component: PositionComponent(point: lowerRight, z: .bottom, rotationDegrees: 0))
                .add(component: TouchableComponent())
                .add(component: HapticFeedbackComponent.shared)
                .add(component: QuadrantComponent(quadrant: .thrustQuadrant))
                .flash(numFlashes, duration: duration, endAlpha: endAlpha, wait: wait)
        hyperspaceEntity
                .add(component: DisplayComponent(sknode: hyperspaceSprite))
                .add(component: PositionComponent(point: upperRight, z: .bottom, rotationDegrees: 0))
                .add(component: TouchableComponent())
                .add(component: HapticFeedbackComponent.shared)
                .add(component: QuadrantComponent(quadrant: .hyperspaceQuadrant))
                .flash(numFlashes, duration: duration, endAlpha: endAlpha, wait: wait)
        // Add the entities to the engine
        engine.add(entity: fireEntity)
        engine.add(entity: flipEntity)
        engine.add(entity: thrustEntity)
        engine.add(entity: hyperspaceEntity)
    }
}
