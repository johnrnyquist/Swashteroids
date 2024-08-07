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

// Entity Names. I use a type alias to make it clear that these are entity names, even though a string is fine to use.
extension String {
    // Ship controls
    static let leftButton: EntityName = "leftButtonEntity"
    static let rightButton: EntityName = "rightButtonEntity"
    static let thrustButton: EntityName = "thrustButtonEntity"
    static let fireButton: EntityName = "fireButtonEntity"
    static let flipButton: EntityName = "flipButtonEntity"
    static let hyperspaceButton: EntityName = "hyperspaceButtonEntity"
    static let fireQuadrant: EntityName = "fireQuadrantEntity"
    static let flipQuadrant: EntityName = "flipQuadrantEntity"
    static let thrustQuadrant: EntityName = "thrustQuadrantEntity"
    static let hyperspaceQuadrant: EntityName = "hyperspaceQuadrantEntity"
    // Start screen
    static let start: EntityName = "startEntity"
    static let noButtons: EntityName = "noButtonsEntity"
    static let withButtons: EntityName = "withButtonsEntity"
    static let tutorialButton: EntityName = "tutorialButtonEntity"
    static let aCircleFill: EntityName = "a.circle.fill"
    static let gamecontrollerFill: EntityName = "gamecontroller.fill"
    // Info screens
    static let buttonsInfoView: EntityName = "buttonsInfoViewEntity"
    static let accelerometerInfoView: EntityName = "accelerometerInfoViewEntity"
    // Misc
    static let alienSoldier: EntityName = "alienSoldierEntity"
    static let alienWorker: EntityName = "alienWorkerEntity"
    static let allSounds: EntityName = "allSoundsEntity"
    static let appState: EntityName = "appStateEntity"
    static let asteroid : EntityName = "asteroidEntity"
    static let gameOver: EntityName = "gameOver"
    static let hud: EntityName = "hudEntity"
    static let hyperspacePowerUp: EntityName = "hyperspacePowerUpEntity"
    static let input: EntityName = "inputEntity"
    static let pauseButton: EntityName = "pauseButtonEntity"
    static let player: EntityName = "playerEntity"
    static let shield: EntityName = "shieldEntity"
    static let shieldPowerUp: EntityName = "shieldsPowerUpEntity"
    static let toggleButton: EntityName = "toggleButtonEntity"
    static let torpedo: EntityName = "torpedoEntity"
    static let torpedoPowerUp: EntityName = "torpedoPowerUpEntity"
    static let tutorialText: EntityName = "tutorialTextEntity"
    static let tutorial: EntityName = "tutorialEntity"
    static let xRayPowerUp: EntityName = "xrayPowerUpEntity"
}
