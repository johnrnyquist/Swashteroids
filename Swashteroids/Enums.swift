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

var LARGE_ASTEROID_RADIUS = 54.0

enum AppState {
    case start
    case infoButtons
    case infoNoButtons
    case playing
    case gameOver
//    case paused
}

enum ShipControlsState {
    case showingButtons
    case hidingButtons
}

enum Toggle: String {
    case on = "On"
    case off = "Off"
}

// zPosition for layers
enum Layer: Double {
    case bottom
    case asteroids
    case torpedoes
    case ship
    case hud
    case buttons
    case top
}

enum RepeatingSoundState {
    case playing
    case notPlaying
    case shouldBegin
    case shouldStop
}
