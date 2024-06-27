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
    let level: Int = 0
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
    let shipControlsState: ShipControlsState = .usingScreenControls
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
    var score: Int {
        didSet {
            if score >= nextShipScore {
                numShips += 1
                nextShipScore += nextShipIncrement
            }
        }
    }
    var shipControlsState: ShipControlsState
    var timePlayed: Double
}

final class AppStateComponent: Component {
    //
    //MARK: - Properties
    let gameConfig: GameConfig
    let randomness: Randomizing
    private var gameState: GameState
    //
    //MARK: - Getters
    var gameSize: CGSize { gameConfig.gameSize }
    var levelBonus: Int { gameState.levelBonus }
    var nextShipIncrement: Int { gameState.nextShipIncrement }
    var nextShipScore: Int { gameState.nextShipScore }
    //
    //MARK: - Getters+Setters
    var alienNextAppearance: TimeInterval {
        get { gameState.alienNextAppearance }
        set { gameState.alienNextAppearance = newValue }
    }
    var appState: AppState {
        get { gameState.appState }
        set { gameState.appState = newValue }
    }
    var level: Int {
        get { gameState.level }
        set { gameState.level = newValue }
    }
    var numHits: Int {
        get { gameState.numHits }
        set { gameState.numHits = newValue }
    }
    var numShips: Int {
        get { gameState.numShips }
        set { gameState.numShips = newValue }
    }
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
    var score: Int {
        get { gameState.score }
        set { gameState.score = newValue }
    }
    var shipControlsState: ShipControlsState {
        get { gameState.shipControlsState }
        set { gameState.shipControlsState = newValue }
    }
    var timePlayed: Double {
        get { gameState.timePlayed }
        set { gameState.timePlayed = newValue }
    }
    //
    //MARK: - Computed Properties
    var alienAppearanceRateDefault: TimeInterval {
//        return 1.0
        return randomness.nextDouble(from: 15.0, through: 90.0)
    }
    var hitPercentage: Int {
        guard gameState.numTorpedoesPlayerFired > 0 else { return 0 }
        return Int(round(Double(numHits) / Double(gameState.numTorpedoesPlayerFired) * 100))
    }
    //
    //MARK: - Initializers
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

    //MARK: - Methods
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
