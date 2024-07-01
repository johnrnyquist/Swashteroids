//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import Foundation
import Swash
import SpriteKit

class StartButtonsCreator: StartButtonsCreatorUseCase {
    private let gameSize: CGSize
    private let startView: StartView
    private weak var engine: Engine!
    private weak var generator: UIImpactFeedbackGenerator?

    init(engine: Engine, gameSize: CGSize, generator: UIImpactFeedbackGenerator?) {
        self.engine = engine
        self.gameSize = gameSize
        self.generator = generator
        startView = StartView(gameSize: gameSize)
    }

    func createStart() {
        startView.name = .start
        let startEntity = Entity(named: .start)
        startView.entity = startEntity
        engine.add(entity: startEntity)
        startEntity
                .add(component: DisplayComponent(sknode: startView))
                .add(component: PositionComponent(x: 0, y: 0, z: .top, rotationDegrees: 0))
    }

    func removeStart() {
        engine.removeEntities(named: [.start, .noButtons, .withButtons])
    }

    func createStartButtons() {
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
        engine.add(entity: noButtons)
        engine.add(entity: withButtons)
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
                        engine.gameStateEntity.add(component: ChangeGameStateComponent(from: .start, to: .infoNoButtons))
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
                        engine.gameStateEntity.add(component: ChangeGameStateComponent(from: .start, to: .infoButtons))
                    },
                    touchUpOutside: { sprite in
                        sprite.alpha = 0.2
                    },
                    touchMoved: { sprite, over in
                        if over { sprite.alpha = 0.6 } else { sprite.alpha = 0.2 }
                    }))
    }

    func removeStartButtons() {
        engine.removeEntities(named: [.noButtons, .withButtons])
    }
}
