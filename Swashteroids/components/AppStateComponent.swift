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
    var alienAppearanceRate: TimeInterval = 0.0
//    var alienAppearanceRateDefault: TimeInterval  { Double.random(in: 20.0...120.0) }
    var alienAppearanceRateDefault: TimeInterval  { 5.0 } // for testing

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
        alienAppearanceRate = alienAppearanceRateDefault
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
