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

extension Transition {
    func fromPlayingScreen() {
        engine.removeEntities(named: [.pauseButton])
        toggleButtonsManager.removeToggleButton()
        shipControlButtonsManager.removeShipControlButtons()
        shipControlQuadrantsManager.removeShipControlQuadrants()
    }

    func toPlayingScreen(appStateComponent: AppStateComponent) {
        appStateComponent.resetBoard()
        hudManager.createHud(gameState: appStateComponent)
        if appStateComponent.shipControlsState == .hidingButtons {
            toggleButtonsManager.createToggleButton(.off)
            shipControlQuadrantsManager.createShipControlQuadrants()
        } else {
            toggleButtonsManager.createToggleButton(.on)
        }
    }
}

