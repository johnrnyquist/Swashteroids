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
    var hudCreator: HudCreator?
    var toggleShipControlsManager: ToggleShipControlsManager?
    var shipControlQuadrantsManager: ShipQuadrantsControlsManager?
    var shipControlButtonsManager: ShipButtonControlsManager?
    private(set) var engine: Engine
    private(set) var generator: UIImpactFeedbackGenerator?
    var size: CGSize {
        if let appStateComponent = engine.appState?[AppStateComponent.name] as? AppStateComponent {
            return appStateComponent.size
        } else {
            return CGSize(width: 0, height: 0)
        }
    }

    convenience init(engine: Engine,
                     creator: HudCreator & ToggleShipControlsManager & ShipQuadrantsControlsManager & ShipButtonControlsManager,
                     generator: UIImpactFeedbackGenerator? = nil) {
        self.init(engine: engine,
                  hudCreator: creator,
                  toggleShipControlsManager: creator,
                  shipControlQuadrantsManager: creator,
                  shipControlButtonsManager: creator,
                  generator: generator)
    }

    init(engine: Engine,
         hudCreator: HudCreator? = nil,
         toggleShipControlsManager: ToggleShipControlsManager? = nil,
         shipControlQuadrantsManager: ShipQuadrantsControlsManager? = nil,
         shipControlButtonsManager: ShipButtonControlsManager? = nil,
         generator: UIImpactFeedbackGenerator? = nil
    ) {
        self.engine = engine
        self.generator = generator
        self.hudCreator = hudCreator
        self.toggleShipControlsManager = toggleShipControlsManager
        self.shipControlQuadrantsManager = shipControlQuadrantsManager
        self.shipControlButtonsManager = shipControlButtonsManager

    }
}
