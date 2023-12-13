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
import Foundation

final class AppStateComponent: Component {
    var size: CGSize
    var numShips = 0
    var level = 0
    var score = 0
    var appState: AppState = .initialize
    var shipControlsState: ShipControlsState = .showingButtons

    init(size: CGSize,
         ships: Int = 3,
         level: Int = 0,
         score: Int = 0,
         appState: AppState = .initialize,
         shipControlsState: ShipControlsState = .showingButtons) {
        self.size = size
        self.numShips = ships
        self.level = level
        self.score = score
        self.appState = appState
        self.shipControlsState = shipControlsState
        super.init()
    }

    func reset() {
        numShips = 3
        level = 0
        score = 0
        appState = .initialize
        shipControlsState = .showingButtons 
    }

    /// Resets the ship, level, and hits.
    func resetBoard() {
        numShips = 3
        level = 0
        score = 0
    }
}
