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
    let hudCreator: HudCreatorUseCase?
    var toggleShipControlsCreator: ToggleShipControlsCreatorUseCase?
    var shipControlQuadrantsCreator: ShipQuadrantsControlsCreatorUseCase?
    var shipButtonControlsCreator: ShipButtonControlsCreatorUseCase?
    private(set) var engine: Engine
    private(set) var generator: UIImpactFeedbackGenerator?
    var gameSize: CGSize {
        engine.appStateComponent.gameSize
    }

    init(engine: Engine,
         hudCreator: HudCreatorUseCase? = nil,
         toggleShipControlsCreator: ToggleShipControlsCreatorUseCase? = nil,
         shipControlQuadrantsCreator: ShipQuadrantsControlsCreatorUseCase? = nil,
         shipButtonControlsCreator: ShipButtonControlsCreatorUseCase? = nil,
         generator: UIImpactFeedbackGenerator? = nil
    ) {
        self.engine = engine
        self.generator = generator
        self.hudCreator = hudCreator
        self.toggleShipControlsCreator = toggleShipControlsCreator
        self.shipControlQuadrantsCreator = shipControlQuadrantsCreator
        self.shipButtonControlsCreator = shipButtonControlsCreator
    }
}
