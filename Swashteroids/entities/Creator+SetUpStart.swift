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
	func tearDownStart() {
		engine.removeEntities(named: [.noButtons, .withButtons, .start])
	}

	func setUpStart() {
        // create the sprites
        let startView = StartView(scene: scene)
        let noButtonsSprite = startView.childNode(withName: "//nobuttons")! as! SwashteroidsSpriteNode
        let buttonsSprite = startView.childNode(withName: "//buttons")! as! SwashteroidsSpriteNode
        noButtonsSprite.removeFromParent()
        buttonsSprite.removeFromParent()
        // create the start entity
        let startEntity = Entity(name: .start)
                .add(component: DisplayComponent(sknode: startView))
                .add(component: PositionComponent(x: 0, y: 0, z: .top, rotation: 0))
        // buttons button
        let withButtons = Entity(name: .withButtons)
                .add(component: DisplayComponent(sknode: buttonsSprite))
                .add(component: PositionComponent(x: buttonsSprite.x, y: buttonsSprite.y, z: Layers.top, rotation: 0))
                .add(component: TouchableComponent())
                .add(component: ButtonBehaviorComponent(
                    touchDown: { [unowned self] sprite in 
                        generator.impactOccurred(); sprite.alpha = 0.6
                    },
                    touchUp: { [unowned self] sprite in
                        sprite.alpha = 0.2
                        appStateEntity.add(component: TransitionAppStateComponent(to: .infoButtons, from: .start))
                    },
                    touchUpOutside: { sprite in 
                        sprite.alpha = 0.2
                    },
                    touchMoved: { sprite, over in
                        if over { sprite.alpha = 0.6 } else { sprite.alpha = 0.2 }
                    }))
        // no buttons button
        let noButtons = Entity(name: .noButtons)
                .add(component: DisplayComponent(sknode: noButtonsSprite))
                .add(component: PositionComponent(x: noButtonsSprite.x,
                                                  y: noButtonsSprite.y,
                                                  z: Layers.top,
                                                  rotation: 0))
                .add(component: TouchableComponent())
                .add(component: ButtonBehaviorComponent(
                    touchDown: { [unowned self] sprite in 
                        generator.impactOccurred(); sprite.alpha = 0.6
                    },
                    touchUp: { [unowned self] sprite in
                        sprite.alpha = 0.2
                        appStateEntity.add(component: TransitionAppStateComponent(to: .infoNoButtons, from: .start))
                    },
                    touchUpOutside: { sprite in 
                        sprite.alpha = 0.2
                    },
                    touchMoved: { sprite, over in
                        if over { sprite.alpha = 0.6 } else { sprite.alpha = 0.2 }
                    }))
        // assign entities to sprites
        startView.entity = startEntity
        noButtonsSprite.entity = noButtons
        buttonsSprite.entity = withButtons
        // add entities to engine
        engine.replaceEntity(entity: startEntity)
        engine.replaceEntity(entity: noButtons)
        engine.replaceEntity(entity: withButtons)
    }
}