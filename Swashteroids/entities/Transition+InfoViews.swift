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

final class InfoViewsTransition: InfoViewsUseCase {
    let engine: Engine
    var gameSize: CGSize {
        engine.gameStateComponent.gameSize
    }

    init(engine: Engine) {
        self.engine = engine
    }

    //MARK: - No buttons state
    func fromAccelerometerInfoScreen() {
        engine.removeEntities(named: [.accelerometerInfoView])
    }

    func toAccelerometerInfoScreen() {
        let noButtonsInfoArt = SKScene(fileNamed: "NoButtonsInfo.sks")!
        guard let viewSprite = noButtonsInfoArt.childNode(withName: "quadrants") as? SwashScaledSpriteNode else {
            fatalError("Could not load 'quadrants' as SwashSpriteNode")
        }
        let background = SwashSpriteNode(color: .clear, size: gameSize)
        background.anchorPoint = CGPoint(x: 0, y: 0)
        viewSprite.removeFromParent()
        background.addChild(viewSprite)
        viewSprite.anchorPoint = CGPoint(x: 0, y: 0)
        viewSprite.position = CGPoint(x: gameSize.width/2, y: gameSize.height/2)
        let viewEntity = Entity(named: .accelerometerInfoView)
                .add(component: ButtonWithAccelerometerInfoComponent())
                .add(component: ButtonComponent())
                .add(component: DisplayComponent(sknode: background))
                .add(component: PositionComponent(x: 0, y: 0, z: .buttons, rotationDegrees: 0))
                .add(component: TouchableComponent())
                .add(component: HapticFeedbackComponent.shared)
        background.entity = viewEntity
        engine.add(entity: viewEntity)
    }

    //MARK: - Buttons showing state
    func fromButtonsInfoScreen() {
        engine.removeEntities(named: [.buttonsInfoView])
    }

    func toButtonsInfoScreen() {
        let viewSprite = SwashSpriteNode(color: .background,
                                         size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        let artSprite = SwashSpriteNode(imageNamed: "infoButtons")
        viewSprite.addChild(artSprite)
        let screenSize = UIScreen.main.bounds.size
        let scaleX = screenSize.width / artSprite.size.width
        let scaleY = screenSize.height / artSprite.size.height
        let scale = min(scaleX, scaleY)
        artSprite.scale = scale
        let viewEntity = Entity(named: .buttonsInfoView)
                .add(component: ButtonWithButtonsInfoComponent())
                .add(component: ButtonComponent())
                .add(component: DisplayComponent(sknode: viewSprite))
                .add(component: PositionComponent(x: gameSize.width / 2, y: gameSize.height / 2, z: .buttons, rotationDegrees: 0))
                .add(component: TouchableComponent())
                .add(component: HapticFeedbackComponent.shared)
        viewSprite.entity = viewEntity
        viewSprite.name = .buttonsInfoView
        engine.add(entity: viewEntity)
    }
}
