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

enum SoundFileName: String, CaseIterable {
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
