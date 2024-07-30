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
import GameController

class ButtonTutorialComponent: Component {}

final class StartScreenCreator: StartScreenCreatorUseCase {
    private let gameSize: CGSize
    private let startView: StartView
    private weak var engine: Engine!

    init(engine: Engine, gameSize: CGSize) {
        self.engine = engine
        self.gameSize = gameSize
        startView = StartView(gameSize: gameSize)
    }

    func createStartScreen() {
        startView.name = .start
        let startEntity = Entity(named: .start)
        startView.entity = startEntity
        engine.add(entity: startEntity)
        startEntity
                .add(component: DisplayComponent(sknode: startView))
                .add(component: PositionComponent(x: 0, y: 0, z: .top, rotationDegrees: 0))
        if engine.gameStateComponent.shipControlsState == .usingGamepad {
            removeStartButtons()
            createGamepadIndicator()
        } else {
            removeGamepadIndicator()
            createStartButtons()
        }
    }

    func removeStartScreen() {
        engine.removeEntities(named: [.start])
        removeStartButtons()
        removeGamepadIndicator()
    }

    
    func removeStartButtons() {
        engine.removeEntities(named: [.tutorialButton, .withButtons])
    }

    func removeGamepadIndicator() {
        engine.removeEntities(named: [.aCircleFill, .gamecontrollerFill])
    }

    func createGamepadIndicator() {
        let aSprite = SwashSpriteNode(imageNamed: .aCircleFill)
        aSprite.setScale(0.33)
        aSprite.anchorPoint = CGPoint(x: 0.5, y: 0)
        let aEntity = Entity(named: .aCircleFill)
                .add(component: DisplayComponent(sknode: aSprite))
                .add(component: PositionComponent(x: gameSize.width - 30,
                                                  y: 20,
                                                  z: .top,
                                                  rotationDegrees: 0))
        engine.add(entity: aEntity)
        let padSprite = SwashSpriteNode(imageNamed: .gamecontrollerFill)
        padSprite.setScale(0.25)
        padSprite.anchorPoint = CGPoint(x: 0.5, y: 0)
        let padEntity = Entity(named: .gamecontrollerFill)
                .add(component: DisplayComponent(sknode: padSprite))
                .add(component: PositionComponent(x: gameSize.width - 30,
                                                  y: 20 + aSprite.size.height,
                                                  z: .top,
                                                  rotationDegrees: 0))
        engine.add(entity: padEntity)
    }

    func createStartButtons() {
        let tutorialSprite = startView.tutorial
        let playSprite = startView.play
        tutorialSprite.name = .tutorialButton
        playSprite.name = .withButtons
        tutorialSprite.removeFromParent()
        playSprite.removeFromParent()
        // create the entities
        let playButton = Entity(named: .withButtons)
        let tutorial = Entity(named: .tutorialButton)
        // assign entities to sprites
        tutorialSprite.entity = tutorial
        playSprite.entity = playButton
        tutorialSprite.entity = tutorial
        // Configure entities
        tutorial
                .add(component: ButtonTutorialComponent())
                .add(component: ButtonComponent())
                .add(component: TouchableComponent())
                .add(component: HapticFeedbackComponent.shared)
                .add(component: DisplayComponent(sknode: tutorialSprite))
                .add(component: PositionComponent(x: tutorialSprite.x, y: tutorialSprite.y, z: Layer.top, rotationDegrees: 0))
        playButton
                .add(component: ButtonWithButtonsComponent())
                .add(component: ButtonComponent())
                .add(component: TouchableComponent())
                .add(component: HapticFeedbackComponent.shared)
                .add(component: DisplayComponent(sknode: playSprite))
                .add(component: PositionComponent(x: playSprite.x, y: playSprite.y, z: Layer.top, rotationDegrees: 0))
        // add entities to engine
        engine.add(entity: tutorial)
        engine.add(entity: playButton)
    }
}
