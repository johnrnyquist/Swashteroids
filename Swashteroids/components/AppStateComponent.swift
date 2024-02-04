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

final class AppStateComponent: Component {
    //MARK: - Set from argument to init
    let gameSize: CGSize
    let randomness: Randomness
    // Original values for resetting
    let orig_appState: AppState
    let orig_level: Int
    let orig_numShips: Int
    let orig_score: Int
    let orig_shipControlsState: ShipControlsState
    // Current values
    var appState: AppState
    var nextShipScore: Int
    var numHits: Int
    var numShips: Int
    var shipControlsState: ShipControlsState
    //
    var level: Int {
        didSet {
            guard level > 1 else { return }
            score += levelBonus
        }
    }
    var score: Int {
        didSet {
            if score >= nextShipScore {
                numShips += 1
                nextShipScore += nextShipIncrement
            }
        }
    }
    var hitPercentage: Int {
        guard numTorpedoesPlayerFired > 0 else { return 0 }
        return Int(round(Double(numHits) / Double(numTorpedoesPlayerFired) * 100))
    }
    //MARK: - Not set from argument to init (yet)
    let levelBonus: Int
    let nextShipIncrement: Int
    var alienAppearanceRate: TimeInterval = 0.0
//    var alienAppearanceRateDefault: TimeInterval { 5.0 }
    var alienAppearanceRateDefault: TimeInterval { randomness.nextDouble(from: 15.0, through: 90.0) }
    var numAliensDestroyed: Int
    var numAsteroidsMined: Int
    var numTorpedoesFired: Int
    var numTorpedoesPlayerFired: Int
    var timePlayed: Double

    init(gameSize: CGSize, numShips: Int, level: Int, score: Int,
         appState: AppState, shipControlsState: ShipControlsState, randomness: Randomness) {
        self.gameSize = gameSize
        self.randomness = randomness
        //
        orig_numShips = numShips
        orig_level = level
        orig_score = score
        orig_appState = appState
        orig_shipControlsState = shipControlsState
        self.numShips = orig_numShips
        self.level = orig_level
        self.score = orig_score
        self.appState = orig_appState
        self.shipControlsState = orig_shipControlsState
        // constants
        levelBonus = 500
        nextShipIncrement = 5_000
        //
        nextShipScore = nextShipIncrement
        numAliensDestroyed = 0
        numAsteroidsMined = 0
        numHits = 0
        numTorpedoesFired = 0
        numTorpedoesPlayerFired = 0
        timePlayed = 0.0
        super.init()
        alienAppearanceRate = alienAppearanceRateDefault
    }

    func resetGame() {
        numShips = orig_numShips
        level = orig_level
        score = orig_score
        appState = orig_appState
        shipControlsState = orig_shipControlsState
        //
        alienAppearanceRate = alienAppearanceRateDefault
        nextShipScore = nextShipIncrement
        numAliensDestroyed = 0
        numAsteroidsMined = 0
        numHits = 0
        numTorpedoesFired = 0
        numTorpedoesPlayerFired = 0
        timePlayed = 0.0
    }
}
