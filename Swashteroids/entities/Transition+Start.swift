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

class StartTransition: StartUseCase {
    let engine: Engine
    let generator: UIImpactFeedbackGenerator?
    var gameSize: CGSize {
        engine.appStateComponent.gameSize
    }

    init(engine: Engine, generator: UIImpactFeedbackGenerator? = nil) {
        self.engine = engine
        self.generator = generator
    }

    func fromStartScreen() {
        engine.removeEntities(named: [.noButtons, .withButtons, .start])
    }

    /// The start screen is not an entity, but composed of entities.  It is the first screen the user sees.
    func toStartScreen() {
        let startView = StartView(gameSize: gameSize)
        startView.name = .start
        let startEntity = Entity(named: .start)
        startView.entity = startEntity
        engine.replace(entity: startEntity)
        startEntity
                .add(component: DisplayComponent(sknode: startView))
                .add(component: PositionComponent(x: 0, y: 0, z: .top, rotationDegrees: 0))
        // TODO: Is the below necessary?
//        if engine.appStateEntity.has(componentClass: GameControllerComponent.self) {
//            return
//        }
        // BUTTONS
        let noButtonsSprite = startView.noButtons
        let buttonsSprite = startView.buttons
        noButtonsSprite.name = .noButtons
        buttonsSprite.name = .withButtons
        noButtonsSprite.removeFromParent()
        buttonsSprite.removeFromParent()
        // create the entities
        let withButtons = Entity(named: .withButtons)
        let noButtons = Entity(named: .noButtons)
        // assign entities to sprites
        noButtonsSprite.entity = noButtons
        buttonsSprite.entity = withButtons
        // add entities to engine
        engine.replace(entity: noButtons)
        engine.replace(entity: withButtons)
        // the button to tap if you want to play with no buttons on the screen
        noButtons
                .add(component: DisplayComponent(sknode: noButtonsSprite))
                .add(component: PositionComponent(x: noButtonsSprite.x, y: noButtonsSprite.y, z: Layer.top, rotationDegrees: 0))
                .add(component: TouchableComponent())
                .add(component: ButtonBehaviorComponent(
                    touchDown: { [unowned self] sprite in
                        generator?.impactOccurred(); sprite.alpha = 0.6
                    },
                    touchUp: { [unowned self] sprite in
                        sprite.alpha = 0.2
                        engine.appStateEntity.add(component: TransitionAppStateComponent(from: .start, to: .infoNoButtons))
                    },
                    touchUpOutside: { sprite in
                        sprite.alpha = 0.2
                    },
                    touchMoved: { sprite, over in
                        if over { sprite.alpha = 0.6 } else { sprite.alpha = 0.2 }
                    }))
        // the button to tap if you want to play with buttons on the screen
        withButtons
                .add(component: DisplayComponent(sknode: buttonsSprite))
                .add(component: PositionComponent(x: buttonsSprite.x, y: buttonsSprite.y, z: Layer.top, rotationDegrees: 0))
                .add(component: TouchableComponent())
                .add(component: ButtonBehaviorComponent(
                    touchDown: { [unowned self] sprite in
                        generator?.impactOccurred()
                        sprite.alpha = 0.6
                    },
                    touchUp: { [unowned self] sprite in
                        sprite.alpha = 0.2
                        engine.appStateEntity.add(component: TransitionAppStateComponent(from: .start, to: .infoButtons))
                    },
                    touchUpOutside: { sprite in
                        sprite.alpha = 0.2
                    },
                    touchMoved: { sprite, over in
                        if over { sprite.alpha = 0.6 } else { sprite.alpha = 0.2 }
                    }))
    }
}
