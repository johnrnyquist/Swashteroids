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

class PlayingTransition: PlayingUseCase {
    weak var hudCreator: HudCreatorUseCase?
    weak var toggleShipControlsCreator: ToggleShipControlsCreatorUseCase?
    weak var shipControlQuadrantsCreator: ShipQuadrantsControlsCreatorUseCase?
    weak var shipButtonControlsCreator: ShipButtonControlsCreatorUseCase?

    init(hudCreator: HudCreatorUseCase,
         toggleShipControlsCreator: ToggleShipControlsCreatorUseCase,
         shipControlQuadrantsCreator: ShipQuadrantsControlsCreatorUseCase,
         shipButtonControlsCreator: ShipButtonControlsCreatorUseCase
    ) {
        self.hudCreator = hudCreator
        self.toggleShipControlsCreator = toggleShipControlsCreator
        self.shipControlQuadrantsCreator = shipControlQuadrantsCreator
        self.shipButtonControlsCreator = shipButtonControlsCreator
    }

    func fromPlayingScreen() {
        toggleShipControlsCreator?.removeToggleButton()
        shipControlQuadrantsCreator?.removeShipControlQuadrants()
        shipButtonControlsCreator?.removeShipControlButtons()
    }

    func toPlayingScreen(appStateComponent: SwashteroidsStateComponent) {
        hudCreator?.createHud(gameState: appStateComponent)
        if appStateComponent.shipControlsState == .usingAccelerometer {
            toggleShipControlsCreator?.createToggleButton(.off)
            shipControlQuadrantsCreator?.createShipControlQuadrants()
        } else {
            toggleShipControlsCreator?.createToggleButton(.on)
        }
    }
}

