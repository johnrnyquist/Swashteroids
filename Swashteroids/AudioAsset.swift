//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//
typealias AudioFileName = String

import Foundation

enum AudioAsset: String, CaseIterable {
    static func validateAudioFilesExist() {
        var errors = [AudioFileName]()
        for asset in AudioAsset.allCases {
            let fileExists = Bundle.main.path(forResource: asset.fileName, ofType: nil) != nil
            if !fileExists {
                errors.append(asset.fileName)
            }
        }
        if !errors.isEmpty {
            fatalError("Missing audio files: \(errors)")
        }
    }

    case alien_entrance
    case explosion
    case hyperspace
    case launch_torpedo
    case level_up
    case powerup
    case powerup_appearance
    case shield_hit
    case thrust
    case toggle
    case treasure
    case treasure_special
    case treasure_standard
    // Tutorial-only sounds
    case tut_collect_treasure
    case tut_congratulations
    case tut_feel_the_roar
    case tut_flipping
    case tut_got_points
    case tut_this_is_your_hud
    case tut_left_right
    case tut_nice_turning
    case tut_no_points
    case tut_these_are_the_powerups
    case tut_this_is_an_asteroid
    case tut_this_is_your_ship
    case tut_try_firing
    case tut_try_hyperspace
    case tut_try_thrust
    case tut_way_to_flip
    case tut_welcome
    var fileName: AudioFileName {
        switch self {
            case .alien_entrance: return "alien_entrance.wav"
            case .explosion: return "explosion.wav"
            case .hyperspace: return "hyperspace.wav"
            case .launch_torpedo: return "launch_torpedo.wav"
            case .level_up: return "level_up.wav"
            case .powerup: return "powerup.wav"
            case .powerup_appearance: return "powerup_appearance.wav"
            case .shield_hit: return "shield_hit.mp3"
            case .thrust: return "thrust.wav"
            case .toggle: return "toggle.wav"
            case .treasure: return "treasure.wav"
            case .treasure_special: return "treasure_special.wav"
            case .treasure_standard: return "treasure_standard.wav"
            case .tut_collect_treasure: return "tut_collect_treasure.mp3"
            case .tut_congratulations: return "tut_congratulations.mp3"
            case .tut_feel_the_roar: return "tut_feel_the_roar.mp3"
            case .tut_flipping: return "tut_flipping.mp3"
            case .tut_got_points: return "tut_got_points.mp3"
            case .tut_this_is_your_hud: return "tut_this_is_your_hud.mp3"
            case .tut_left_right: return "tut_left_right.mp3"
            case .tut_nice_turning: return "tut_nice_turning.mp3"
            case .tut_no_points: return "tut_no_points.mp3"
            case .tut_these_are_the_powerups: return "tut_these_are_the_powerups.mp3"
            case .tut_this_is_an_asteroid: return "tut_this_is_an_asteroid.mp3"
            case .tut_this_is_your_ship: return "tut_this_is_your_ship.mp3"
            case .tut_try_firing: return "tut_try_firing.mp3"
            case .tut_try_hyperspace: return "tut_try_hyperspace.mp3"
            case .tut_try_thrust: return "tut_try_thrust.mp3"
            case .tut_way_to_flip: return "tut_way_to_flip.mp3"
            case .tut_welcome: return "tut_welcome.mp3"
        }
    }
}