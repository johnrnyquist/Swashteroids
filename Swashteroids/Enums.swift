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

var LARGE_ASTEROID_RADIUS = 54.0
var POWER_UP_RADIUS = 7.0
// TODO: Is this AppState or GameState? Start, playing, gameover, paused all seem like game states. infoButtons and infoNoButtons seem like app states.
enum AppState {
    case start
    case infoButtons
    case infoNoButtons
    case playing
    case gameOver
}

/// The state of the ship controls. Either showing or hiding. 
enum ShipControlsState {
    case showingButtons
    case hidingButtons
}

enum Toggle: String {
    case on = "On"
    case off = "Off"
}

enum RepeatingSoundState {
    case playing
    case notPlaying
    case shouldBegin
    case shouldStop
}
