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

extension Transition {
    func fromStartScreen() {
        engine.removeEntities(named: [.noButtons, .withButtons, .start])
    }

    /// The start screen is not an entity, but composed of entities.  It is the first screen the user sees.
    func toStartScreen() {
        // create the sprites
        let startView = StartView(gameSize: gameSize)
        let noButtonsSprite = startView.noButtons
        let buttonsSprite = startView.buttons
        startView.name = .start
        noButtonsSprite.name = .noButtons
        buttonsSprite.name = .withButtons
        noButtonsSprite.removeFromParent()
        buttonsSprite.removeFromParent()
        // create the entities
        let startEntity = Entity(named: .start)
        let withButtons = Entity(named: .withButtons)
        let noButtons = Entity(named: .noButtons)
        // assign entities to sprites
        startView.entity = startEntity
        noButtonsSprite.entity = noButtons
        buttonsSprite.entity = withButtons
        // add entities to engine
        engine.replace(entity: startEntity)
        engine.replace(entity: noButtons)
        engine.replace(entity: withButtons)
        // configure the entities
        startEntity
                .add(component: DisplayComponent(sknode: startView))
                .add(component: PositionComponent(x: 0, y: 0, z: .top, rotationDegrees: 0))
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
                        engine.appState?.add(component: TransitionAppStateComponent(from: .start, to: .infoNoButtons))
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
                        engine.appState?.add(component: TransitionAppStateComponent(from: .start, to: .infoButtons))
                    },
                    touchUpOutside: { sprite in
                        sprite.alpha = 0.2
                    },
                    touchMoved: { sprite, over in
                        if over { sprite.alpha = 0.6 } else { sprite.alpha = 0.2 }
                    }))
    }
}
