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
    var alienNextAppearance: TimeInterval = Randomness.shared.nextDouble(from: 15.0, through: 90.0)
    var gameSize: CGSize
    var level: Int = 0
    var levelBonus: Int = 500
    var nextShipIncrement: Int = 5_000
    var nextShipScore: Int = 5_000
    var numAliensDestroyed: Int = 0
    var numAsteroidsMined: Int = 0
    var numHits: Int = 0
    var numShips: Int = 3
    var numTorpedoesFired: Int = 0
    var numTorpedoesPlayerFired: Int = 0
    var score: Int = 0
    var shipControlsState: ShipControlsState = .usingScreenControls
    var swashteroidsState: GameScreen = .start
    var timePlayed: Double = 0.0
}

struct Playing {
    var alienNextAppearance: TimeInterval
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

final class GameStateComponent: Component {
    //MARK: - Properties
    var gameScreen: GameScreen 
    let config: GameConfig
    let randomness: Randomizing
    private var playing: Playing
    //
    //MARK: - Getters
    var gameSize: CGSize { config.gameSize }
    var levelBonus: Int { playing.levelBonus }
    var nextShipIncrement: Int { playing.nextShipIncrement }
    var nextShipScore: Int { playing.nextShipScore }
    //
    //MARK: - Getters+Setters
    var alienNextAppearance: TimeInterval {
        get { playing.alienNextAppearance }
        set { playing.alienNextAppearance = newValue }
    }
    var level: Int {
        get { playing.level }
        set { playing.level = newValue }
    }
    var numHits: Int {
        get { playing.numHits }
        set { playing.numHits = newValue }
    }
    var numShips: Int {
        get { playing.numShips }
        set { playing.numShips = newValue }
    }
    var numAliensDestroyed: Int {
        get { playing.numAliensDestroyed }
        set { playing.numAliensDestroyed = newValue }
    }
    var numAsteroidsMined: Int {
        get { playing.numAsteroidsMined }
        set { playing.numAsteroidsMined = newValue }
    }
    var numTorpedoesFired: Int {
        get { playing.numTorpedoesFired }
        set { playing.numTorpedoesFired = newValue }
    }
    var numTorpedoesPlayerFired: Int {
        get { playing.numTorpedoesPlayerFired }
        set { playing.numTorpedoesPlayerFired = newValue }
    }
    var score: Int {
        get { playing.score }
        set { playing.score = newValue }
    }
    var shipControlsState: ShipControlsState {
        get { playing.shipControlsState }
        set { playing.shipControlsState = newValue }
    }
    var timePlayed: Double {
        get { playing.timePlayed }
        set { playing.timePlayed = newValue }
    }
    //
    //MARK: - Computed Properties
    var alienAppearanceRateDefault: TimeInterval {
//        return 5.0
        return randomness.nextDouble(from: 15.0, through: 90.0)
    }
    var hitPercentage: Int {
        guard playing.numTorpedoesPlayerFired > 0 else { return 0 }
        return Int(round(Double(numHits) / Double(playing.numTorpedoesPlayerFired) * 100))
    }
    //
    //MARK: - Initializers
    init(config: GameConfig, randomness: Randomizing = Randomness.shared) {
        self.config = config
        self.randomness = randomness
        gameScreen = config.swashteroidsState
        //
        playing = Playing(
            alienNextAppearance: config.alienNextAppearance,
            level: config.level,
            levelBonus: config.levelBonus,
            nextShipIncrement: config.nextShipIncrement,
            nextShipScore: config.nextShipScore,
            numAliensDestroyed: config.numAliensDestroyed,
            numAsteroidsMined: config.numAsteroidsMined,
            numHits: config.numHits,
            numShips: config.numShips,
            numTorpedoesFired: config.numTorpedoesFired,
            numTorpedoesPlayerFired: config.numTorpedoesPlayerFired,
            score: config.score,
            shipControlsState: config.shipControlsState,
            timePlayed: config.timePlayed
        )
        super.init()
    }

    //MARK: - Methods
    func resetPlaying() {
        playing = Playing(
            alienNextAppearance: config.alienNextAppearance,
            level: config.level,
            levelBonus: config.levelBonus,
            nextShipIncrement: config.nextShipIncrement,
            nextShipScore: config.nextShipScore,
            numAliensDestroyed: config.numAliensDestroyed,
            numAsteroidsMined: config.numAsteroidsMined,
            numHits: config.numHits,
            numShips: config.numShips,
            numTorpedoesFired: config.numTorpedoesFired,
            numTorpedoesPlayerFired: config.numTorpedoesPlayerFired,
            score: config.score,
            shipControlsState: config.shipControlsState,
            timePlayed: config.timePlayed
        )
    }
}
