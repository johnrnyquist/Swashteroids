//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import XCTest
@testable import Swashteroids
@testable import Swash
import SpriteKit

final class AlienCreatorUseCaseTests: XCTestCase {
    var engine: Engine!

    override func setUpWithError() throws {
        engine = Engine()
        let appState = Entity(named: .appState)
        appState.add(component: AppStateComponent(gameSize: .zero,
                                                  numShips: 0,
                                                  level: 1,
                                                  score: 0,
                                                  appState: .playing,
                                                  shipControlsState: .showingButtons,
                                                  randomness: Randomness.initialize(with: 1)))
        try! engine.add(entity: appState)
    }

    override func tearDownWithError() throws {
        engine = nil
    }
    
    func test_createAlienWorker_hasPlayer() throws {
        let player = Entity(named: .player)
        try! engine.add(entity: player)
        let creator = AlienCreator(engine: engine,
                                   size: .zero,
                                   randomness: Randomness.initialize(with: 1))
        creator.createAlienWorker(startDestination: .zero, endDestination: .zero)
        XCTAssertNotNil(engine.findEntity(named: "alienWorkerEntity_1"))
    }

    func test_createAlienWorker_noPlayer() throws {
        let creator = AlienCreator(engine: engine,
                                   size: .zero,
                                   randomness: Randomness.initialize(with: 1))
        creator.createAlienWorker(startDestination: .zero, endDestination: .zero)
        XCTAssertNil(engine.findEntity(named: "alienWorkerEntity_1"))
    }

    func test_createAlienSoldier_hasPlayer() throws {
        let player = Entity(named: .player)
        try! engine.add(entity: player)
        let creator = AlienCreator(engine: engine,
                                   size: .zero,
                                   randomness: Randomness.initialize(with: 1))
        creator.createAlienSoldier(startDestination: .zero, endDestination: .zero)
        XCTAssertNotNil(engine.findEntity(named: "alienSoldierEntity_1"))
    }

    func test_createAlienSoldier_noPlayer() throws {
        let creator = AlienCreator(engine: engine,
                                   size: .zero,
                                   randomness: Randomness.initialize(with: 1))
        creator.createAlienSoldier(startDestination: .zero, endDestination: .zero)
        XCTAssertNil(engine.findEntity(named: "alienSoldierEntity_1"))
    }
}
