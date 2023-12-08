import Swash

let LARGE_ASTEROID_RADIUS = 54.0

enum ShipControlsState {
    case showingButtons
    case hidingButtons
}

enum Toggle {
    case on
    case off
}

// zPosition for layers
enum Layers: Double {
    case bottom
    case asteroids
    case bullets
    case ship
    case hud
    case buttons
    case top
}

// Entity Names
extension String {
    // Ship controls
    static let leftButton: EntityName = "leftButtonEntity"
    static let rightButton: EntityName = "rightButtonEntity"
    static let thrustButton: EntityName = "thrustButtonEntity"
    static let fireButton: EntityName = "fireButtonEntity"
    static let flipButton: EntityName = "flipButtonEntity"
    static let hyperSpaceButton: EntityName = "hyperSpaceButtonEntity"
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
    // 
    static let appState: EntityName = "appStateEntity"
    static let hud: EntityName = "hudEntity"
    static let gameOver: EntityName = "gameOver"
    static let inputEntity: EntityName = "inputEntity"
    static let plasmaTorpedoesPowerUp: EntityName = "plasmaTorpedoesPowerUpEntity"
    static let toggleButton: EntityName = "toggleButtonEntity"
    static let ship: EntityName = "ship"
}

// System Priorities
extension Int {
    static let preUpdate = 1
    static let update = 2
    static let move = 3
    static let resolveCollisions = 4
    static let stateMachines = 5
    static let animate = 6
    static let render = 7
}

