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
    //MARK: - No buttons state
	func fromNoButtonsInfoScreen() {
		engine.removeEntities(named: [.noButtonsInfoView])
	}

	func toNoButtonsInfoScreen() {
        let noButtonsInfoArt = SKScene(fileNamed: "NoButtonsInfo.sks")!
        guard let viewSprite = noButtonsInfoArt.childNode(withName: "quadrants") as? SwashSpriteNode else {
            print("Could not load 'quadrants' as SwashSpriteNode")
            return
        }
        viewSprite.removeFromParent()
        let viewEntity = Entity(name: .noButtonsInfoView)
                .add(component: DisplayComponent(sknode: viewSprite))
                .add(component: PositionComponent(x: 0, y: 0, z: .buttons, rotation: 0))
                .add(component: TouchableComponent())
                .add(component: ButtonBehaviorComponent(
                    touchDown: { [unowned self] sprite in
                        generator.impactOccurred()
                        engine.appState?.add(component: TransitionAppStateComponent(to: .playing, from: .infoNoButtons))
                    }))
        viewSprite.entity = viewEntity
        engine.replaceEntity(entity: viewEntity)
    }


    //MARK: - Buttons showing state
	func fromButtonsInfoScreen() {
		engine.removeEntities(named: [.buttonsInfoView])
	}

    func toButtonsInfoScreen() {
        let buttonsInfoArt = SKScene(fileNamed: "ButtonsInfo.sks")!
        guard let viewSprite = buttonsInfoArt.childNode(withName: "buttonsInfo") as? SwashSpriteNode else {
            print("Could not load 'buttonsInfo' as SwashSpriteNode")
            return
        }
        viewSprite.removeFromParent()
        shipControlButtonsManager.createShipControlButtons()
        let viewEntity = Entity(name: .buttonsInfoView)
                .add(component: DisplayComponent(sknode: viewSprite))
                .add(component: PositionComponent(x: 0, y: 0, z: .buttons, rotation: 0))
                .add(component: TouchableComponent())
                .add(component: ButtonBehaviorComponent(touchDown: { [unowned self] sprite in
                    generator.impactOccurred()
                    engine.appState?.add(component: TransitionAppStateComponent(to: .playing, from: .infoButtons))
                }))
        viewSprite.entity = viewEntity
        engine.replaceEntity(entity: viewEntity)
    }
}
