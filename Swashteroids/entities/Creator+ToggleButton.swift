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

    func createToggleButton(_ toggleState: Toggle) {
        let name = toggleState == .on ? "toggleButtonsOn" : "toggleButtonsOff"
        let sprite = SwashteroidsSpriteNode(imageNamed: name)
        sprite.name = name
        sprite.alpha = 0.2
        let x = scene.size.width / 2
        let y = 90.0
        let toggleEntity = Entity(name: .toggleButton)
                .add(component: PositionComponent(x: x, y: y, z: .buttons))
                .add(component: DisplayComponent(sknode: sprite))
                .add(component: TouchableComponent())
        sprite.entity = toggleEntity
        // Add the button behavior
        let toState: ShipControlsState = toggleState == .on ? .hidingButtons : .showingButtons
        toggleEntity.add(component: ButtonBehaviorComponent(
            touchDown: { [unowned self, unowned toggleEntity] sprite in
				generator.impactOccurred()
				(engine.getEntity(named: .appState)?[AppStateComponent.name] as? AppStateComponent)?.shipControlsState = toState //HACK
                engine.hud?.add(component: ChangeShipControlsStateComponent(to: toState))
                toggleEntity
                        .add(component: AudioComponent(fileNamed: "toggle.wav", withKey: "toggle"))
            },
            touchUp: { sprite in sprite.alpha = 0.2 },
            touchUpOutside: { sprite in sprite.alpha = 0.2 },
            touchMoved: { sprite, over in
                if over { sprite.alpha = 0.6 } else { sprite.alpha = 0.2 }
            }
        ))
        engine.replaceEntity(entity: toggleEntity)
    }
}
