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
    static let q1: EntityName = "q1Entity"
    static let q2: EntityName = "q2Entity"
    static let q3: EntityName = "q3Entity"
    static let q4: EntityName = "q4Entity"
    // Start screen
    static let start: EntityName = "startEntity"
    static let noButtons: EntityName = "noButtonsEntity"
    static let withButtons: EntityName = "withButtonsEntity"
    // Info screens
    static let buttonsInfoView: EntityName = "buttonsInfoViewEntity"
    static let noButtonsInfoView: EntityName = "noButtonsInfoViewEntity"
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
    static let player: EntityName = "playerEnity"
    static let toggleButton: EntityName = "toggleButtonEntity"
    static let torpedo: EntityName = "torpedoEntity"
    static let torpedoPowerUp: EntityName = "torpedoPowerUpEntity"
}
