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

struct GameConfig {
    let alienNextAppearance: TimeInterval = 0.0
    let appState: AppState = .start
    let gameSize: CGSize
    let level: Int = 1 //TODO: 0 or 1?
    let levelBonus: Int = 500
    let nextShipIncrement: Int = 5_000
    let nextShipScore: Int = 5_000
    let numAliensDestroyed: Int = 0
    let numAsteroidsMined: Int = 0
    let numHits: Int = 0
    let numShips: Int = 3
    let numTorpedoesFired: Int = 0
    let numTorpedoesPlayerFired: Int = 0
    let score: Int = 0
    let shipControlsState: ShipControlsState = .showingButtons
    let timePlayed: Double = 0.0
}

struct GameState {
    var alienNextAppearance: TimeInterval
    var appState: AppState
    var level: Int {
        didSet {
            guard level > 1 else { return }
            score += levelBonus
        }
    }
    var levelBonus: Int
    var nextShipIncrement: Int
    var nextShipScore: Int
    var numAliensDestroyed: Int
    var numAsteroidsMined: Int
    var numHits: Int
    var numShips: Int
    var numTorpedoesFired: Int
    var numTorpedoesPlayerFired: Int
    var score: Int
    var shipControlsState: ShipControlsState
    var timePlayed: Double
}

final class AppStateComponent: Component {
    let gameConfig: GameConfig
    var randomness: Randomizing
    var gameState: GameState
    var gameSize: CGSize { gameConfig.gameSize }
    var appState: AppState {
        get { gameState.appState }
        set { gameState.appState = newValue }
    }
    var nextShipScore: Int { gameState.nextShipScore }
    var numHits: Int {
        get { gameState.numHits }
        set { gameState.numHits = newValue }
    }
    var numShips: Int { 
        get { gameState.numShips }
        set { gameState.numShips = newValue }
    }
    var shipControlsState: ShipControlsState {
        get { gameState.shipControlsState }
        set { gameState.shipControlsState = newValue }
    }
    var level: Int {
        get { gameState.level }
        set { gameState.level = newValue }
    }
    var score: Int = 0 {
        didSet {
            if gameState.score >= gameState.nextShipScore {
                gameState.numShips += 1
                gameState.nextShipScore += gameState.nextShipIncrement
            }
        }
    }
    var hitPercentage: Int {
        guard gameState.numTorpedoesPlayerFired > 0 else { return 0 }
        return Int(round(Double(numHits) / Double(gameState.numTorpedoesPlayerFired) * 100))
    }
    var levelBonus: Int { gameState.levelBonus }
    var nextShipIncrement: Int { gameState.nextShipIncrement }
    var alienNextAppearance: TimeInterval {
        get { gameState.alienNextAppearance }
        set { gameState.alienNextAppearance = newValue }
    }
    #if DEBUG
        var alienAppearanceRateDefault: TimeInterval { 1.0 }
    #else
        var alienAppearanceRateDefault: TimeInterval { randomness.nextDouble(from: 15.0, through: 90.0) }
    #endif
    var numAliensDestroyed: Int {
        get { gameState.numAliensDestroyed }
        set { gameState.numAliensDestroyed = newValue }
    }
    var numAsteroidsMined: Int {
        get { gameState.numAsteroidsMined }
        set { gameState.numAsteroidsMined = newValue }
    }
    var numTorpedoesFired: Int {
        get { gameState.numTorpedoesFired }
        set { gameState.numTorpedoesFired = newValue }
    }
    var numTorpedoesPlayerFired: Int {
        get { gameState.numTorpedoesPlayerFired }
        set { gameState.numTorpedoesPlayerFired = newValue }
    }
    var timePlayed: Double {
        get { gameState.timePlayed }
        set { gameState.timePlayed = newValue }
    }

    init(gameConfig: GameConfig,
         randomness: Randomizing = Randomness.shared) {
        self.gameConfig = gameConfig
        self.randomness = randomness
        //
        gameState = GameState(
            alienNextAppearance: gameConfig.alienNextAppearance,
            appState: gameConfig.appState,
            level: gameConfig.level,
            levelBonus: gameConfig.levelBonus,
            nextShipIncrement: gameConfig.nextShipIncrement,
            nextShipScore: gameConfig.nextShipScore,
            numAliensDestroyed: gameConfig.numAliensDestroyed,
            numAsteroidsMined: gameConfig.numAsteroidsMined,
            numHits: gameConfig.numHits,
            numShips: gameConfig.numShips,
            numTorpedoesFired: gameConfig.numTorpedoesFired,
            numTorpedoesPlayerFired: gameConfig.numTorpedoesPlayerFired,
            score: gameConfig.score,
            shipControlsState: gameConfig.shipControlsState,
            timePlayed: gameConfig.timePlayed
        )
        super.init()
    }

    func resetGame() {
        gameState = GameState(
            alienNextAppearance: gameConfig.alienNextAppearance,
            appState: gameConfig.appState,
            level: gameConfig.level,
            levelBonus: gameConfig.levelBonus,
            nextShipIncrement: gameConfig.nextShipIncrement,
            nextShipScore: gameConfig.nextShipScore,
            numAliensDestroyed: gameConfig.numAliensDestroyed,
            numAsteroidsMined: gameConfig.numAsteroidsMined,
            numHits: gameConfig.numHits,
            numShips: gameConfig.numShips,
            numTorpedoesFired: gameConfig.numTorpedoesFired,
            numTorpedoesPlayerFired: gameConfig.numTorpedoesPlayerFired,
            score: gameConfig.score,
            shipControlsState: gameConfig.shipControlsState,
            timePlayed: gameConfig.timePlayed
        )
    }
}
