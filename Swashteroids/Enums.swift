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

enum AsteroidAttributes {
    static let large = 54.0
}

/// The state of the ship controls. Either showing or hiding. 
enum ShipControlsState {
    case usingAccelerometer
    case usingGamepad
    case usingScreenControls
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

enum GameCommand: String, CaseIterable {
    // Playing
    case fire = "Fire"
    case thrust = "Thrust"
    case hyperspace = "Hyperspace"
    case left = "Left"
    case right = "Right"
    case flip = "Flip"
    case pause = "Pause"
    // Alert
    case home = "Home"
    case resume = "Resume"
    case settings = "Settings"
    // Start
    // Info
    case play = "Play"
}

public enum GameScreen: String, CaseIterable {
    case start = "Start Screen"
    case infoButtons = "Buttons Information Screen"
    case infoAccelerometer = "No Buttons Information Screen"
    case playing = "Playing Screen"
    case gameOver = "Game Over Screen"
    case tutorial = "Tutorial"
    var commandsPerScreen: [GameCommand] {
        switch self {
            case .start:
                return [.play]
            case .infoButtons:
                return [.play]
            case .infoAccelerometer:
                return [.play]
            case .playing:
                return [.fire, .thrust, .hyperspace, .left, .right, .pause, .flip, .home, .settings, .resume]
            case .gameOver:
                return [.pause, .home, .settings, .resume]
            case .tutorial:
                return [.play]
        }
    }
}
