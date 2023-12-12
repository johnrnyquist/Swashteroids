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

extension Creator {
    //MARK: - No buttons state
	func transitionFromNoButtonsInfoScreen() {
		engine.removeEntities(named: [.noButtonsInfoView])
	}

	func transitionToNoButtonsInfoScreen() {
        let noButtonsInfoArt = SKScene(fileNamed: "NoButtonsInfo.sks")!
        guard let viewSprite = noButtonsInfoArt.childNode(withName: "quadrants") as? SwashteroidsSpriteNode else {
            print("Could not load 'quadrants' as SwashteroidsSpriteNode")
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
	func tranistionFromButtonsInfoScreen() {
		engine.removeEntities(named: [.buttonsInfoView])
	}

    func transitionToButtonsInfoScreen() {
        let buttonsInfoArt = SKScene(fileNamed: "ButtonsInfo.sks")!
        guard let viewSprite = buttonsInfoArt.childNode(withName: "buttonsInfo") as? SwashteroidsSpriteNode else {
            print("Could not load 'buttonsInfo' as SwashteroidsSpriteNode")
            return
        }
        viewSprite.removeFromParent()
        createShipControlButtons()
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
