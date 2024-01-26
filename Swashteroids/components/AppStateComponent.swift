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
    // Original values for resetting
    let orig_numShips: Int
    let orig_level: Int
    let orig_score: Int
    let orig_appState: AppState
    let orig_shipControlsState: ShipControlsState
    // Current values
    var appState: AppState
    var nextShipScore = 5_000
    var numShips: Int
    var shipControlsState: ShipControlsState
    var numTorpedoesFired = 0
    var numHits = 0
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
        guard numTorpedoesFired > 0 else { return 0 }
        return Int(round(Double(numHits) / Double(numTorpedoesFired) * 100))
    }
    //MARK: - Not set from argument to init (yet)
    let levelBonus = 500
    let nextShipIncrement = 5_000
    var alienAppearanceRate: TimeInterval = 0.0
//    var alienAppearanceRateDefault: TimeInterval { 5.0 }
//    var alienAppearanceRateDefault: TimeInterval { Double.random(in: 15.0...90.0) }
    var alienAppearanceRateDefault: TimeInterval { randomness.nextDouble(from: 15.0, through: 90.0) }
    var numAliensDestroyed = 0
    var numAsteroidsMined = 0
    let randomness: Randomness

    init(gameSize: CGSize, numShips: Int, level: Int, score: Int,
         appState: AppState, shipControlsState: ShipControlsState, randomness: Randomness) {
        self.gameSize = gameSize
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
        self.randomness = randomness
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
        nextShipScore = 5_000
        alienAppearanceRate = alienAppearanceRateDefault
        numTorpedoesFired = 0
    }
}
