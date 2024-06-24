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

class InfoViewsTransition: InfoViewsUseCase {
    let engine: Engine
    let generator: UIImpactFeedbackGenerator?
    var gameSize: CGSize {
        engine.appStateComponent.gameSize
    }

    init(engine: Engine, generator: UIImpactFeedbackGenerator?) {
        self.engine = engine
        self.generator = generator
    }

    //MARK: - No buttons state
    func fromNoButtonsInfoScreen() {
        engine.removeEntities(named: [.noButtonsInfoView])
    }

    func toNoButtonsInfoScreen() {
        let noButtonsInfoArt = SKScene(fileNamed: "NoButtonsInfo.sks")!
        guard let viewSprite = noButtonsInfoArt.childNode(withName: "quadrants") as? SwashScaledSpriteNode else {
            fatalError("Could not load 'quadrants' as SwashSpriteNode")
        }

        viewSprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        viewSprite.removeFromParent()
        let viewEntity = Entity(named: .noButtonsInfoView)
                .add(component: DisplayComponent(sknode: viewSprite))
                .add(component: PositionComponent(x: gameSize.width / 2, y: gameSize.height / 2, z: .buttons, rotationDegrees: 0))
                .add(component: TouchableComponent())
                .add(component: ButtonBehaviorComponent(
                    touchDown: { [unowned self] sprite in
                        generator?.impactOccurred()
                        engine.appStateEntity.add(component: TransitionAppStateComponent(from: .infoNoButtons, to: .playing))
                    }))
        viewSprite.entity = viewEntity
        engine.add(entity: viewEntity)
    }

    //MARK: - Buttons showing state
    func fromButtonsInfoScreen() {
        engine.removeEntities(named: [.buttonsInfoView])
    }

    func toButtonsInfoScreen() {
        let viewSprite = SwashSpriteNode(color: .background,
                                         size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        let artSprite = SKSpriteNode(imageNamed: "infoButtons")
        viewSprite.addChild(artSprite)
        let screenSize = UIScreen.main.bounds.size
        let scaleX = screenSize.width / artSprite.size.width
        let scaleY = screenSize.height / artSprite.size.height
        let scale = min(scaleX, scaleY)
        artSprite.scale = scale
        let viewEntity = Entity(named: .buttonsInfoView)
                .add(component: DisplayComponent(sknode: viewSprite))
                .add(component: PositionComponent(x: gameSize.width / 2, y: gameSize.height / 2, z: .buttons, rotationDegrees: 0))
                .add(component: TouchableComponent())
                .add(component: ButtonBehaviorComponent(touchDown: { [unowned self] sprite in
                    generator?.impactOccurred()
                    engine.appStateEntity.add(component: TransitionAppStateComponent(from: .infoButtons, to: .playing))
                }))
        viewSprite.entity = viewEntity
        viewSprite.name = .buttonsInfoView
        engine.add(entity: viewEntity)
    }
}
