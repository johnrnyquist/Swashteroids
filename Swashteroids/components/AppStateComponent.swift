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
    var numShips: Int
    var level: Int
    var score: Int
    var appState: AppState
    var shipControlsState: ShipControlsState

    init(size: CGSize,
         ships: Int,
         level: Int,
         score: Int,
         appState: AppState,
         shipControlsState: ShipControlsState) {
        self.size = size
        self.numShips = ships
        self.level = level
        self.score = score
        self.appState = appState
        self.shipControlsState = shipControlsState
        super.init()
    }

    func reset() {
        resetBoard()
        appState = .start
        shipControlsState = .showingButtons 
    }

    /// Resets the ship, level, and hits.
    func resetBoard() {
        numShips = 3
        level = 0
        score = 0
    }
}
