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

final class AppStateComponent: Component {
    var ships = 0
    var level = 0
    var score = 0
    var playing = false
    var appState: AppState = .initialize
    var shipControlsState: ShipControlsState = .showingButtons

    /// Resets the ship, level, and hits.
    func resetBoard() {
        ships = 3
        level = 0
        score = 0
    }
}
