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

// HACK 
var LARGE_ASTEROID_RADIUS = 54.0
var MEDIUM_ASTEROID_RADIUS = 27.0
var SMALL_ASTEROID_RADIUS = 13.5
var POWER_UP_RADIUS = 7.0

enum Functionality: String, CaseIterable {
    // Playing
    case fire = "Fire"
    case thrust = "Thrust"
    case hyperspace = "Hyperspace"
    case left = "Left"
    case right = "Right"
    case pause = "Pause"
    case flip = "Flip"
    // Alert
    case home = "Home"
    case resume = "Resume"
    case settings = "Settings"
    // Start
    case buttons = "Buttons"
    case noButtons = "No Buttons"
    // Info
    case `continue` = "Continue"
}

//TODO: Refactor global variable 
var screenSpecificFunctionalities: [AppState: [Functionality]] = [
    .start: [.buttons, .noButtons],
    .infoButtons: [.continue],
    .infoNoButtons: [.continue],
    .playing: [.fire, .thrust, .hyperspace, .left, .right, .pause, .flip],
    .gameOver: [.pause, .home, .settings, .resume]
]
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
    case usingAccelerometer
    case usingGameController
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

enum SoundFileNames: String, CaseIterable {
    case alienEntrance = "alien_entrance.wav"
    case explosion = "bang_large.wav"
    case levelUpSound = "braam-6150.wav"
    case launchTorpedo = "fire.wav"
    case hyperspace = "hyperspace.wav"
    case powerUp = "powerup.wav"
    case powerUpAppearance = "powerup_appearance.wav"
    case thrust = "thrust.wav"
    case toggle = "toggle.wav"
    case treasure = "treasure.wav"
    case treasureSpecial = "treasure_special.wav"
    case treasureStandard = "treasure_standard.wav"
}
