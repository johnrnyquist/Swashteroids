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

final class ShipButtonControlsCreator: ShipButtonControlsCreatorUseCase {
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
        button.entity = buttonEntity
        engine.add(entity: buttonEntity)
        return buttonEntity
    }

    // HACK
    func showFireButton() {
        if let fireButtonEntity,
           engine.gameStateComponent.shipControlsState == .usingScreenControls {
            engine.add(entity: fireButtonEntity)
            let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
            let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: 0.2)
            let seq = SKAction.sequence([fadeIn, fadeOut])
            let sprite = engine.findEntity(named: .fireButton)?[DisplayComponent.self]?.sprite
            sprite?.run(seq)
        }
    }

    // HACK 
    func showHyperspaceButton() {
        if let hyperspaceButtonEntity,
           engine.gameStateComponent.shipControlsState == .usingScreenControls {
            engine.add(entity: hyperspaceButtonEntity)
            let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
            let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: 0.2)
            let seq = SKAction.sequence([fadeIn, fadeOut])
            let sprite = (engine.findEntity(named: .hyperspaceButton)?[DisplayComponent.name] as? DisplayComponent)?.sprite
            sprite?.run(seq)
        }
    }

    func createShipControlButtons() {
        // left
        let leftButton = SwashScaledSpriteNode(imageNamed: .leftButton)
        let leftX = leftButton.size.width / 2 + buttonPaddingLeft
        let leftY = leftButton.size.height / 2 + firstRowButtonPaddingY
        createButtonEntity(sprite: leftButton, color: .leftButton, position: CGPoint(x: leftX, y: leftY), named: .leftButton)
        // right
        let rightButton = SwashScaledSpriteNode(imageNamed: .rightButton)
        let rightX = rightButton.size.width + buttonPadding + leftX
        let rightY = leftY
        createButtonEntity(sprite: rightButton, color: .rightButton, position: CGPoint(x: rightX, y: rightY), named: .rightButton)
        // thrust
        let thrustButton = SwashScaledSpriteNode(imageNamed: .thrustButton)
        let thrustX = size.width - thrustButton.size.width / 2 - buttonPaddingRight
        let thrustY = leftY
        createButtonEntity(sprite: thrustButton,
                           color: .thrustButton,
                           position: CGPoint(x: thrustX, y: thrustY),
                           named: .thrustButton)
        // fire
        let fireButton = SwashScaledSpriteNode(imageNamed: .fireButton)
        let fireX = -thrustButton.size.width - buttonPadding + thrustX
        let fireY = leftY
        // I'm storing the fire button so it can be added and removed from the engine without re-creating.
        fireButtonEntity = createButtonEntity(sprite: fireButton,
                                              color: .fireButton,
                                              position: CGPoint(x: fireX, y: fireY),
                                              named: .fireButton)
        // flip
        let flipButton = SwashScaledSpriteNode(imageNamed: .flipButton)
        let flipX = leftX
        let flipY = leftY + flipButton.size.height + buttonPadding
        createButtonEntity(sprite: flipButton, color: .flipButton, position: CGPoint(x: flipX, y: flipY), named: .flipButton)
        // hyperspace
        let hyperspaceButton = SwashScaledSpriteNode(imageNamed: .hyperspaceButton)
        let hyperspaceX = thrustX
        let hyperspaceY = flipY
        // I'm storing the fire button so it can be added and removed from the engine without re-creating.
        hyperspaceButtonEntity = createButtonEntity(sprite: hyperspaceButton,
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
                  .add(component: ButtonHyperSpaceComponent())
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
