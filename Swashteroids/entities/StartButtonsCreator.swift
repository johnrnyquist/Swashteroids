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

class StartButtonsCreator: StartButtonsCreatorUseCase {
    private let gameSize: CGSize
    private let startView: StartView
    private weak var engine: Engine!

    init(engine: Engine, gameSize: CGSize) {
        self.engine = engine
        self.gameSize = gameSize
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
        engine.removeEntities(named: [.start, .noButtons, .withButtons, .aCircleFill, .gamecontrollerFill])
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
        // the button to tap if you want to play with no buttons on the screen
        noButtons
                .add(component: ButtonWithAccelerometerComponent())
                .add(component: ButtonComponent())
                .add(component: TouchableComponent())
                .add(component: HapticFeedbackComponent.shared)
                .add(component: DisplayComponent(sknode: noButtonsSprite))
                .add(component: PositionComponent(x: noButtonsSprite.x, y: noButtonsSprite.y, z: Layer.top, rotationDegrees: 0))
        // the button to tap if you want to play with buttons on the screen
        withButtons
                .add(component: ButtonWithButtonsComponent())
                .add(component: ButtonComponent())
                .add(component: TouchableComponent())
                .add(component: HapticFeedbackComponent.shared)
                .add(component: DisplayComponent(sknode: buttonsSprite))
                .add(component: PositionComponent(x: buttonsSprite.x, y: buttonsSprite.y, z: Layer.top, rotationDegrees: 0))
        // add entities to engine
        engine.add(entity: noButtons)
        engine.add(entity: withButtons)

        if GCController.isGameControllerConnected() {
            let a = SwashSpriteNode(imageNamed: .aCircleFill)
            a.setScale(0.33)
            a.anchorPoint = CGPoint(x: 0.5, y: 0)
            let aEntity = Entity(named: .aCircleFill)
                    .add(component: DisplayComponent(sknode: a))
                    .add(component: PositionComponent(x: gameSize.width - 30,
                                                      y: 20,
                                                      z: .top,
                                                      rotationDegrees: 0))
            engine.add(entity: aEntity)
            let controller = SwashSpriteNode(imageNamed: .gamecontrollerFill)
            controller.setScale(0.25)
            controller.anchorPoint = CGPoint(x: 0.5, y: 0)
            let controllerEntity = Entity(named: .gamecontrollerFill)
                    .add(component: DisplayComponent(sknode: controller))
                    .add(component: PositionComponent(x: gameSize.width - 30,
                                                      y: 20 + a.size.height,
                                                      z: .top,
                                                      rotationDegrees: 0))
            engine.add(entity: controllerEntity)
        }

    }

    func removeStartButtons() {
        engine.removeEntities(named: [.noButtons, .withButtons, .aCircleFill, .gamecontrollerFill])
    }
}
