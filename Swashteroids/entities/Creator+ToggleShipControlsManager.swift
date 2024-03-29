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

extension Creator: ToggleShipControlsManager {
    func removeToggleButton() {
        guard let entity = engine.findEntity(named: .toggleButton) else { return }
        engine.remove(entity: entity)
    }

    func createToggleButton(_ toggleState: Toggle) {
        let name = toggleState == .on ? "toggleButtonsOn" : "toggleButtonsOff"
        let sprite = SwashScaledSpriteNode(imageNamed: name)
        sprite.name = name
        sprite.alpha = 0.2
        let x = size.width / 2
        let y = 90.0 * scaleManager.SCALE_FACTOR
        let toggleEntity = Entity(named: .toggleButton)
                .add(component: PositionComponent(x: x, y: y, z: .buttons))
                .add(component: DisplayComponent(sknode: sprite))
                .add(component: TouchableComponent())
        sprite.entity = toggleEntity
        // Add the button behavior
        let toState: ShipControlsState = toggleState == .on ? .hidingButtons : .showingButtons
        toggleEntity.add(component: ButtonBehaviorComponent(
            touchDown: { [unowned self] sprite in
                generator?.impactOccurred()
                (engine.appState?[
                    AppStateComponent.name
                    ] as? AppStateComponent)?.shipControlsState = toState //HACK remove? Add TransitionAppStateComponent?
                engine.hud?.add(component: ChangeShipControlsStateComponent(to: toState))
                engine.hud?.add(component: AudioComponent(fileNamed: .toggle,
                                                          actionKey: "toggle\(toggleState.rawValue)"))
            },
            touchUp: { sprite in sprite.alpha = 0.2 },
            touchUpOutside: { sprite in sprite.alpha = 0.2 },
            touchMoved: { sprite, over in
                if over { sprite.alpha = 0.6 } else { sprite.alpha = 0.2 }
            }
        ))
        engine.replace(entity: toggleEntity)
    }
}
