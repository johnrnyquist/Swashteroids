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

extension Transition: PlayingUseCase {
    func fromPlayingScreen() {
        toggleShipControlsCreator?.removeToggleButton()
        shipControlQuadrantsCreator?.removeShipControlQuadrants()
        shipButtonControlsCreator?.removeShipControlButtons()
    }

    func toPlayingScreen(appStateComponent: AppStateComponent) {
        hudCreator?.createHud(gameState: appStateComponent)
        if appStateComponent.shipControlsState == .hidingButtons {
            toggleShipControlsCreator?.createToggleButton(.off)
            shipControlQuadrantsCreator?.createShipControlQuadrants()
        } else {
            toggleShipControlsCreator?.createToggleButton(.on)
        }
    }
}

