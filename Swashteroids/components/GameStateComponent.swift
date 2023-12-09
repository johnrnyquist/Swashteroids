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
    var ships = 0
    var level = 0
    var score = 0
    var playing = false
    var appState: AppState = .initialize
    var shipControlsState: ShipControlsState = .showingButtons

    init(size: CGSize,
         ships: Int = 3,
         level: Int = 0,
         score: Int = 0,
         playing: Bool = false,
         appState: AppState = .initialize,
         shipControlsState: ShipControlsState = .showingButtons) {
        self.size = size
        self.ships = ships
        self.level = level
        self.score = score
        self.playing = playing
        self.appState = appState
        self.shipControlsState = shipControlsState
        super.init()
    }

    /// Resets the ship, level, and hits.
    func resetBoard() {
        ships = 3
        level = 0
        score = 0
    }
}
