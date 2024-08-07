//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import SpriteKit

enum AssetImage: String, CaseIterable {
    static func validateImageFilesExist() {
        var errors = [String]()
        for asset in AssetImage.allCases {
            let fileExists = UIImage(named: asset.name) != nil
            if !fileExists {
                errors.append(asset.name)
            }
        }
        if !errors.isEmpty {
            fatalError("Missing image files: \(errors)")
        }
    }

    case alienSoldier
    case alienSoldierLeftPiece
    case alienSoldierRightPiece
    case alienSoldierLeftDamaged
    case alienSoldierBothDamaged
    case alienWorker
    case fireButton
    case flipButton
    case gamecontroller
    case gradientLeft
    case gradientRight
    case hyperspaceButton
    case hyperspacePowerUp
    case leftButton
    case letterA
    case pause
    case play
    case rightButton
    case rocks_left
    case rocks_right
    case shield
    case ship
    case swashLogo
    case thrustButton
    case title
    case toggleButtonsOff
    case toggleButtonsOn
    case torpedoPowerUp
    case training
    case tunnel
    case xray
    var sprite: SKSpriteNode {
        SKSpriteNode(imageNamed: name)
    }
    var swashSprite: SwashSpriteNode {
        SwashSpriteNode(imageNamed: name)
    }
    var swashScaledSprite: SwashScaledSpriteNode {
        SwashScaledSpriteNode(imageNamed: name)
    }
    var name: String {
        switch self {
            case .alienSoldier: return "alienSoldier"
            case .alienSoldierLeftPiece: return "alienSoldierLeftPiece"
            case .alienSoldierRightPiece: return "alienSoldierRightPiece"
            case .alienSoldierLeftDamaged: return "alienSoldierLeftBroke"
            case .alienSoldierBothDamaged: return "alienSoldierBothBroke"

            case .alienWorker: return "alienWorker"
            case .fireButton: return "fireButton"
            case .flipButton: return "flipButton"
            case .gamecontroller: return "gamecontroller.fill"
            case .gradientLeft: return "gradientLeft"
            case .gradientRight: return "gradientRight"
            case .hyperspaceButton: return "hyperspaceButton"
            case .hyperspacePowerUp: return "hyperspacePowerUp"
            case .leftButton: return "leftButton"
            case .letterA: return "a.circle.fill"
            case .pause: return "pause"
            case .play: return "play"
            case .rightButton: return "rightButton"
            case .rocks_left: return "rocks_left"
            case .rocks_right: return "rocks_right"
            case .shield: return "circle_dotted_circle"
            case .ship: return "ship"
            case .swashLogo: return "swash"
            case .thrustButton: return "thrustButton"
            case .title: return "title"
            case .toggleButtonsOff: return "toggleButtonsOff"
            case .toggleButtonsOn: return "toggleButtonsOn"
            case .torpedoPowerUp: return "torpedoPowerUp"
            case .training: return "training"
            case .tunnel: return "spiral"
            case .xray: return "visionpro_circle"
        }
    }
}

