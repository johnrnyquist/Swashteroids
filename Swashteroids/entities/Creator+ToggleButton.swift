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
    func removeToggleButton() {
        guard let entity = engine.getEntity(named: .toggleButton) else { return }
        engine.removeEntity(entity: entity)
    }

    func createToggleButton(_ state: Toggle) {
        let name = state == .on ? "toggleButtonsOn" : "toggleButtonsOff"
        let sprite = SwashteroidsSpriteNode(imageNamed: name)
        sprite.name = name
        sprite.alpha = 0.2
        let x = scene.size.width / 2
        let y = 90.0
        let toggleButtonsEntity = Entity(name: .toggleButton)
                .add(component: PositionComponent(x: x, y: y, z: .buttons))
                .add(component: DisplayComponent(sknode: sprite))
                .add(component: TouchableComponent())
        sprite.entity = toggleButtonsEntity
        // Add the button behavior
        let toState: ShipControlsState = state == .on ? .hidingButtons : .showingButtons
        toggleButtonsEntity.add(component: ButtonBehaviorComponent(
            touchDown: { [unowned self] sprite in
                engine.hud?.add(component: ChangeShipControlsStateComponent(to: toState))
            },
            touchUp: { sprite in sprite.alpha = 0.2 },
            touchUpOutside: { sprite in sprite.alpha = 0.2 },
            touchMoved: { sprite, over in
                if over { sprite.alpha = 0.6 } else { sprite.alpha = 0.2 }
            }
        ))
        engine.replaceEntity(entity: toggleButtonsEntity)
    }
}