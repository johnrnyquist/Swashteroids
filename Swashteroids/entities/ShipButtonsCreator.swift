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

extension Entity {
    @discardableResult
    func flash(_ numFlashes: Int = 1, duration: TimeInterval = 0.2, endAlpha: Double = 0.2, wait: TimeInterval = 0) -> Entity {
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: duration)
        let wait = SKAction.wait(forDuration: wait)
        let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: duration)
        let flashes = Array(repeating: [fadeIn, fadeOut], count: numFlashes).flatMap { $0 }
        let flashSeq = SKAction.sequence(flashes)
        let seq = SKAction.sequence([flashSeq, wait, SKAction.fadeAlpha(to: CGFloat(endAlpha), duration: duration)])
        let sknode = self[DisplayComponent.self]?.sknode
        sknode?.run(seq)
        return self
    }
}

final class ShipButtonsCreator: ShipButtonCreatorUseCase {
    weak var engine: Engine!
    var size: CGSize
    var buttonPadding = 30.0
    var buttonPaddingLeft = 30.0
    var buttonPaddingRight = 30.0
    var firstRowButtonPaddingY = 30.0
    var fireButtonEntity: Entity? //HACK Creator should NOT be holding onto this reference!
    var hyperspaceButtonEntity: Entity? //HACK Creator should NOT be holding onto this reference!
    var scaleManager: ScaleManaging

    init(engine: Engine,
         size: CGSize,
         scaleManager: ScaleManaging = ScaleManager.shared,
         randomness: Randomizing = Randomness.shared
    ) {
        self.scaleManager = scaleManager
        buttonPadding *= scaleManager.SCALE_FACTOR
        buttonPaddingLeft *= scaleManager.SCALE_FACTOR
        buttonPaddingRight *= scaleManager.SCALE_FACTOR
        firstRowButtonPaddingY *= scaleManager.SCALE_FACTOR
        self.engine = engine
        self.size = size
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
           let window = appDelegate.window {
            buttonPaddingLeft += max(window.safeAreaInsets.left, 10)
            buttonPaddingRight += max(window.safeAreaInsets.right, 10)
            firstRowButtonPaddingY += max(window.safeAreaInsets.bottom, 10)
        }
    }

    func removeShipControlButtons() {
        let shipControls: [EntityName] = [.leftButton, .rightButton, .thrustButton, .fireButton, .flipButton, .hyperspaceButton]
        engine.removeEntities(named: shipControls)
    }

    @discardableResult
    func createButtonEntity(sprite button: SwashScaledSpriteNode, color: UIColor, position: CGPoint, named: EntityName) -> Entity {
        button.color = color
        button.colorBlendFactor = 1.0
        button.name = named
        button.alpha = 0.2
        let buttonEntity = Entity(named: named)
                .add(component: PositionComponent(x: position.x, y: position.y, z: .buttons, rotationDegrees: 0.0))
                .add(component: DisplayComponent(sknode: button))
        button.swashEntity = buttonEntity
        engine.add(entity: buttonEntity)
        return buttonEntity
    }

    // HACK called from CollisionSystem
    func showFireButton() {
        if let fireButtonEntity,
           engine.gameStateComponent.shipControlsState == .usingScreenControls {
            engine.add(entity: fireButtonEntity)
            fireButtonEntity.flash()
        }
    }

    // HACK called from CollisionSystem 
    func showHyperspaceButton() {
        if let hyperspaceButtonEntity,
           engine.gameStateComponent.shipControlsState == .usingScreenControls {
            engine.add(entity: hyperspaceButtonEntity)
            hyperspaceButtonEntity.flash()
        }
    }

    func createThrustButton() {
        let thrustSprite = SwashScaledSpriteNode(imageNamed: .thrustButton)
        let thrustX = size.width - thrustSprite.size.width / 2 - buttonPaddingRight
        let thrustY = thrustSprite.size.height / 2 + firstRowButtonPaddingY
        createButtonEntity(sprite: thrustSprite,
                           color: .thrustButton,
                           position: CGPoint(x: thrustX, y: thrustY),
                           named: .thrustButton)
                .add(component: TouchableComponent())
                .add(component: ButtonComponent())
                .add(component: HapticFeedbackComponent.shared)
                .add(component: ButtonThrustComponent())
                .flash(3)
    }

    func createLeftButton() {
        let leftSprite = SwashScaledSpriteNode(imageNamed: .leftButton)
        let leftX = leftSprite.size.width / 2 + buttonPaddingLeft
        let leftY = leftSprite.size.height / 2 + firstRowButtonPaddingY
        createButtonEntity(sprite: leftSprite,
                           color: .leftButton,
                           position: CGPoint(x: leftX, y: leftY),
                           named: .leftButton)
                .add(component: TouchableComponent())
                .add(component: ButtonComponent())
                .add(component: HapticFeedbackComponent.shared)
                .add(component: ButtonLeftComponent())
                .flash(3)
    }

    func createRightButton() {
        let rightSprite = SwashScaledSpriteNode(imageNamed: .rightButton)
        let leftX = rightSprite.size.width / 2 + buttonPaddingLeft
        let rightX = rightSprite.size.width + buttonPadding + leftX
        let rightY = rightSprite.size.height / 2 + firstRowButtonPaddingY
        createButtonEntity(sprite: rightSprite,
                           color: .rightButton,
                           position: CGPoint(x: rightX, y: rightY),
                           named: .rightButton)
                .add(component: TouchableComponent())
                .add(component: ButtonComponent())
                .add(component: HapticFeedbackComponent.shared)
                .add(component: ButtonRightComponent())
                .flash(3)
    }

    func createFlipButton() {
        let flipSprite = SwashScaledSpriteNode(imageNamed: .flipButton)
        let flipX = flipSprite.size.width / 2 + buttonPaddingLeft
        let flipY = flipSprite.size.height / 2 + firstRowButtonPaddingY + flipSprite.size.height + buttonPadding
        createButtonEntity(sprite: flipSprite,
                           color: .flipButton,
                           position: CGPoint(x: flipX, y: flipY),
                           named: .flipButton)
                .add(component: TouchableComponent())
                .add(component: ButtonComponent())
                .add(component: HapticFeedbackComponent.shared)
                .add(component: ButtonFlipComponent())
                .flash(3)
    }

    func createFireButton() {
        let fireSprite = SwashScaledSpriteNode(imageNamed: .fireButton)
        let thrustSprite = SwashScaledSpriteNode(imageNamed: .thrustButton)
        let thrustX = size.width - thrustSprite.size.width / 2 - buttonPaddingRight
        let fireX = -thrustSprite.size.width - buttonPadding + thrustX
        let leftSprite = SwashScaledSpriteNode(imageNamed: .leftButton)
        let leftY = leftSprite.size.height / 2 + firstRowButtonPaddingY
        let fireY = leftY
        // I'm storing the fire button so it can be added and removed from the engine without re-creating.
        fireButtonEntity = createButtonEntity(sprite: fireSprite,
                                              color: .fireButton,
                                              position: CGPoint(x: fireX, y: fireY),
                                              named: .fireButton)
                .add(component: TouchableComponent())
                .add(component: ButtonComponent())
                .add(component: HapticFeedbackComponent.shared)
                .add(component: ButtonFireComponent())
        fireButtonEntity?[DisplayComponent.self]?.sprite?.alpha = 0.0
    }

    func createHyperspaceButton() {
        let hyperspaceSprite = SwashScaledSpriteNode(imageNamed: .hyperspaceButton)
        let thrustSprite = SwashScaledSpriteNode(imageNamed: .thrustButton)
        let thrustX = size.width - thrustSprite.size.width / 2 - buttonPaddingRight
        let hyperspaceX = thrustX
        let leftSprite = SwashScaledSpriteNode(imageNamed: .leftButton)
        let leftY = leftSprite.size.height / 2 + firstRowButtonPaddingY
        let flipSprite = SwashScaledSpriteNode(imageNamed: .flipButton)
        let flipY = leftY + flipSprite.size.height + buttonPadding
        let hyperspaceY = flipY
        // I'm storing the fire button so it can be added and removed from the engine without re-creating.
        hyperspaceButtonEntity = createButtonEntity(sprite: hyperspaceSprite,
                                                    color: .hyperspaceButton,
                                                    position: CGPoint(x: hyperspaceX, y: hyperspaceY),
                                                    named: .hyperspaceButton)
                .add(component: TouchableComponent())
                .add(component: ButtonComponent())
                .add(component: HapticFeedbackComponent.shared)
                .add(component: ButtonHyperspaceComponent())
        hyperspaceButtonEntity?[DisplayComponent.self]?.sprite?.alpha = 0.0
    }

    func createShipControlButtons() {
        // left
        let leftSprite = SwashScaledSpriteNode(imageNamed: .leftButton)
        let leftX = leftSprite.size.width / 2 + buttonPaddingLeft
        let leftY = leftSprite.size.height / 2 + firstRowButtonPaddingY
        createButtonEntity(sprite: leftSprite, color: .leftButton, position: CGPoint(x: leftX, y: leftY), named: .leftButton)
        // right
        let rightSprite = SwashScaledSpriteNode(imageNamed: .rightButton)
        let rightX = rightSprite.size.width + buttonPadding + leftX
        let rightY = leftY
        createButtonEntity(sprite: rightSprite, color: .rightButton, position: CGPoint(x: rightX, y: rightY), named: .rightButton)
        // thrust
        let thrustSprite = SwashScaledSpriteNode(imageNamed: .thrustButton)
        let thrustX = size.width - thrustSprite.size.width / 2 - buttonPaddingRight
        let thrustY = leftY
        createButtonEntity(sprite: thrustSprite,
                           color: .thrustButton,
                           position: CGPoint(x: thrustX, y: thrustY),
                           named: .thrustButton)
        // fire
        let fireSprite = SwashScaledSpriteNode(imageNamed: .fireButton)
        let fireX = -thrustSprite.size.width - buttonPadding + thrustX
        let fireY = leftY
        // I'm storing the fire button so it can be added and removed from the engine without re-creating.
        fireButtonEntity = createButtonEntity(sprite: fireSprite,
                                              color: .fireButton,
                                              position: CGPoint(x: fireX, y: fireY),
                                              named: .fireButton)
        // flip
        let flipSprite = SwashScaledSpriteNode(imageNamed: .flipButton)
        let flipX = leftX
        let flipY = leftY + flipSprite.size.height + buttonPadding
        createButtonEntity(sprite: flipSprite, color: .flipButton, position: CGPoint(x: flipX, y: flipY), named: .flipButton)
        // hyperspace
        let hyperspaceSprite = SwashScaledSpriteNode(imageNamed: .hyperspaceButton)
        let hyperspaceX = thrustX
        let hyperspaceY = flipY
        // I'm storing the fire button so it can be added and removed from the engine without re-creating.
        hyperspaceButtonEntity = createButtonEntity(sprite: hyperspaceSprite,
                                                    color: .hyperspaceButton,
                                                    position: CGPoint(x: hyperspaceX, y: hyperspaceY),
                                                    named: .hyperspaceButton)
    }

    func enableShipControlButtons() {
        guard let flip = engine.findEntity(named: .flipButton),
              let hyperspace = engine.findEntity(named: .hyperspaceButton),
              let left = engine.findEntity(named: .leftButton),
              let right = engine.findEntity(named: .rightButton),
              let thrust = engine.findEntity(named: .thrustButton),
              let fire = engine.findEntity(named: .fireButton)
        else {
            print(#function, #line, "WARNING: could not find all buttons in engine")
            return
        }
        flip.add(component: TouchableComponent())
            .add(component: ButtonComponent())
            .add(component: HapticFeedbackComponent.shared)
            .add(component: ButtonFlipComponent())
        hyperspace.sprite?.alpha = 0.0 //HACK to hide this button until you get the power-up
        hyperspace.add(component: TouchableComponent())
                  .add(component: ButtonComponent())
                  .add(component: HapticFeedbackComponent.shared)
                  .add(component: ButtonHyperspaceComponent())
        left.add(component: TouchableComponent())
            .add(component: ButtonComponent())
            .add(component: HapticFeedbackComponent.shared)
            .add(component: ButtonLeftComponent())
        right.add(component: TouchableComponent())
             .add(component: ButtonComponent())
             .add(component: HapticFeedbackComponent.shared)
             .add(component: ButtonRightComponent())
        thrust.add(component: TouchableComponent())
              .add(component: ButtonComponent())
              .add(component: HapticFeedbackComponent.shared)
              .add(component: ButtonThrustComponent())
        fire.sprite?.alpha = 0.0 //HACK to hide this button until you get the power-up
        fire.add(component: TouchableComponent())
            .add(component: ButtonComponent())
            .add(component: HapticFeedbackComponent.shared)
            .add(component: ButtonFireComponent())
    }
}
