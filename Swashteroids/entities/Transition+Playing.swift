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
        creator.removeToggleButton()
        creator.removeShipControlButtons()
        creator.removeShipControlQuadrants()
    }
        
    func toPlayingScreen(with state: ShipControlsState) {
        guard let appStateComponent = engine.getEntity(named: .appState)?
                                            .get(componentClassName: AppStateComponent.name) as? AppStateComponent else {
            print("WARNING: appStateComponent not found in engine")
            return
        }
        appStateComponent.resetBoard()
        creator.createHud(gameState: appStateComponent)
        if state == .hidingButtons {
            creator.createToggleButton(.off)
            creator.createShipControlQuadrants()
        } else {
            creator.createToggleButton(.on)
            creator.enableShipControlButtons()
        }
    }
}

