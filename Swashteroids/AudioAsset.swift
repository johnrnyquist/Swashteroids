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
    case level_up
    case collect_treasure
    case congratulations
    case feel
    case launch_torpedo
    case flipping
    case got_points
    case hud
    case hyperspace
    case left_right
    case nice_turning
    case no_points
    case powerup
    case powerup_appearance
    case shield_hit
    case these_are_the_powerups
    case this_is_an_asteroid
    case this_is_your_ship
    case thrust
    case toggle
    case treasure
    case treasure_special
    case treasure_standard
    case try_firing
    case try_hyperspace
    case try_thrust
    case way_to_flip
    case welcome
    var fileName: AudioFileName {
        switch self {
            case .alien_entrance: return "alien_entrance.wav"
            case .explosion: return "bang_large.wav"
            case .level_up: return "braam-6150.wav"
            case .collect_treasure: return "collect_treasure.mp3"
            case .congratulations: return "congratulations.mp3"
            case .feel: return "feel.mp3"
            case .launch_torpedo: return "fire.wav"
            case .flipping: return "flipping.mp3"
            case .got_points: return "got_points.mp3"
            case .hud: return "hud.mp3"
            case .hyperspace: return "hyperspace.wav"
            case .left_right: return "left_right.mp3"
            case .nice_turning: return "nice_turning.mp3"
            case .no_points: return "no_points.mp3"
            case .powerup: return "powerup.wav"
            case .powerup_appearance: return "powerup_appearance.wav"
            case .shield_hit: return "shield_hit.mp3"
            case .these_are_the_powerups: return "these_are_the_powerups.mp3"
            case .this_is_an_asteroid: return "this_is_an_asteroid.mp3"
            case .this_is_your_ship: return "this_is_your_ship.mp3"
            case .thrust: return "thrust.wav"
            case .toggle: return "toggle.wav"
            case .treasure: return "treasure.wav"
            case .treasure_special: return "treasure_special.wav"
            case .treasure_standard: return "treasure_standard.wav"
            case .try_firing: return "try_firing.mp3"
            case .try_hyperspace: return "try_hyperspace.mp3"
            case .try_thrust: return "try_thrust.mp3"
            case .way_to_flip: return "way_to_flip.mp3"
            case .welcome: return "welcome.mp3"
        }
    }
}