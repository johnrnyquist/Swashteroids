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

class Transition {
    var hudManager: HudManager
    var toggleButtonsManager: ToggleButtonManager
    var shipControlQuadrantsManager: ShipControlQuadrantsManager
    var shipControlButtonsManager: ShipControlButtonsManager
    var engine: Engine
    var generator: UIImpactFeedbackGenerator
    var size: CGSize {
        if let appStateComponent = engine.appState?[AppStateComponent.name] as? AppStateComponent {
            return appStateComponent.size
        } else {
            return CGSize(width: 0, height: 0)
        }
    }

    init(engine: Engine, creator: Creator, generator: UIImpactFeedbackGenerator) {
        self.engine = engine
        self.generator = generator
        hudManager = creator
        toggleButtonsManager = creator
        shipControlQuadrantsManager = creator
        shipControlButtonsManager = creator
    }
}
