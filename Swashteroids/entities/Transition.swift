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

final class Transition {
    var hudCreator: HudCreatorUseCase?
    var toggleShipControlsManager: ToggleShipControlsManagerUseCase?
    var shipControlQuadrantsManager: ShipQuadrantsControlsManagerUseCase?
    var shipControlButtonsManager: ShipButtonControlsManagerUseCase?
    private(set) var engine: Engine
    private(set) var generator: UIImpactFeedbackGenerator?
    var gameSize: CGSize {
        engine.appStateComponent.gameSize
    }

    convenience init(engine: Engine,
                     creator: HudCreatorUseCase & ToggleShipControlsManagerUseCase & ShipQuadrantsControlsManagerUseCase & ShipButtonControlsManagerUseCase,
                     generator: UIImpactFeedbackGenerator? = nil) {
        self.init(engine: engine,
                  hudCreator: creator,
                  toggleShipControlsManager: creator,
                  shipControlQuadrantsManager: creator,
                  shipControlButtonsManager: creator,
                  generator: generator)
    }

    init(engine: Engine,
         hudCreator: HudCreatorUseCase? = nil,
         toggleShipControlsManager: ToggleShipControlsManagerUseCase? = nil,
         shipControlQuadrantsManager: ShipQuadrantsControlsManagerUseCase? = nil,
         shipControlButtonsManager: ShipButtonControlsManagerUseCase? = nil,
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
