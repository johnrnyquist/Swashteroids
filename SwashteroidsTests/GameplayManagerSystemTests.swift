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
import SpriteKit
@testable import Swash
@testable import Swashteroids

final class GameplayManagerSystemTests: XCTestCase {
    var engine: Engine!
    var scene: GameScene!
    var alienCreator: MockAlienCreator!
    var asteroidCreator: MockAsteroidCreator!
    var shipCreator: ShipCreatorUseCase!
    var system: GameplayManagerSystem!
    var appStateComponent: AppStateComponent!

    override func setUpWithError() throws {
        engine = Engine()
        alienCreator = MockAlienCreator()
        asteroidCreator = MockAsteroidCreator()
        shipCreator = MockShipCreator()
        scene = GameScene()
        appStateComponent = AppStateComponent(gameSize: .zero,
                                              numShips: 0,
                                              level: 1,
                                              score: 0,
                                              appState: .playing,
                                              shipControlsState: .showingButtons,
                                              randomness: Randomness.initialize(with: 1))
        system = GameplayManagerSystem(asteroidCreator: asteroidCreator,
                                       alienCreator: alienCreator,
                                       shipCreator: shipCreator,
                                       size: CGSize(width: 1024, height: 768),
                                       scene: scene,
                                       randomness: Randomness.initialize(with: 1),
                                       scaleManager: MockScaleManager())
    }

    override func tearDownWithError() throws {
        scene = nil
        alienCreator = nil
        engine = nil
    }

    func test_IsClearToAddSpaceship() {
        engine.add(system: system, priority: 1)
        let asteroid = Entity(named: "asteroid")
                .add(component: AsteroidComponent(size: .large))
                .add(component: CollidableComponent(radius: LARGE_ASTEROID_RADIUS,
                                                    scaleManager: MockScaleManager()))
                .add(component: PositionComponent(x: 0, y: 0, z: .asteroids))
                .add(component: VelocityComponent(velocityX: 0, velocityY: 0, base: 60.0))
        try? engine.add(entity: asteroid)
        let suggestedShipLocation = CGPoint(x: 100, y: 100)
        let result = system.isClearToAddSpaceship(at: suggestedShipLocation)
        XCTAssertTrue(result)
    }

    func test_IsNotClearToAddSpaceship() {
        engine.add(system: system, priority: 1)
        let asteroid = Entity(named: "asteroid")
                .add(component: AsteroidComponent(size: .large))
                .add(component: CollidableComponent(radius: LARGE_ASTEROID_RADIUS,
                                                    scaleManager: MockScaleManager()))
                .add(component: PositionComponent(x: 0, y: 0, z: .asteroids))
                .add(component: VelocityComponent(velocityX: 0, velocityY: 0, base: 60.0))
        try? engine.add(entity: asteroid)
        let suggestedShipLocation = CGPoint(x: 0, y: 0)
        // SUT
        let result = system.isClearToAddSpaceship(at: suggestedShipLocation)
        //
        XCTAssertFalse(result)
    }

    func test_CreatePowerUps() {
        engine.add(system: system, priority: 1)
        //TODO: Add assertions
    }

    func test_CreateAsteroids() {
        engine.add(system: system, priority: 1)
        // SUT
        system.createAsteroids(count: 2, avoiding: .zero, level: 1)
        // 
        XCTAssertEqual(asteroidCreator.createAsteroidCalled, 2)
    }

    func test_GoToNextLevel() {
        let system = MockGameManagerSystem_GoToNextLevel(asteroidCreator: asteroidCreator,
                                                         alienCreator: alienCreator,
                                                         shipCreator: shipCreator,
                                                         size: CGSize(width: 1024, height: 768),
                                                         scene: scene, randomness: Randomness.initialize(with: 1),
                                                         scaleManager: MockScaleManager())
        let shipEntity = Entity(named: .player)
                .add(component: PositionComponent(x: 0, y: 0, z: .ship))
                .add(component: ShipComponent())
        try? engine.add(entity: shipEntity)
        engine.add(system: system, priority: 1)
        system.goToNextLevel(appStateComponent: appStateComponent, entity: shipEntity)
        XCTAssertEqual(appStateComponent.level, 2)
        XCTAssertTrue(system.announceLevelCalled)
        XCTAssertEqual(system.createAsteroidsCalled, 1)

        class MockGameManagerSystem_GoToNextLevel: GameplayManagerSystem {
            var announceLevelCalled = false
            var createAsteroidsCalled = 0

            override func announceLevel(appStateComponent: AppStateComponent) {
                announceLevelCalled = true
            }

            override func createAsteroids(count: Int, avoiding positionToAvoid: CGPoint, level: Int) {
                createAsteroidsCalled += 1
            }
        }
    }

    func xtest_HandlePlayingState_HavingShips_IsClearToAddShips() {
        let system = MockGameManagerSystem_HandlePlayingState(asteroidCreator: asteroidCreator,
                                                              alienCreator: alienCreator,
                                                              shipCreator: shipCreator,
                                                              size: CGSize(width: 1024, height: 768),
                                                              scene: scene, randomness: Randomness.initialize(with: 1),
                                                              scaleManager: MockScaleManager())
        system.continueOrEnd(appStateComponent: appStateComponent, entity: Entity())
        XCTAssertEqual(system.isClearToAddSpaceshipCalled, true)
        XCTAssertEqual(system.createPowerUpsCalled, true)

        class MockGameManagerSystem_HandlePlayingState: GameplayManagerSystem {
            var isClearToAddSpaceshipCalled = false
            var createPowerUpsCalled = false

            override func isClearToAddSpaceship(at position: CGPoint) -> Bool {
                isClearToAddSpaceshipCalled = true
                return true
            }
        }
    }

    func test_HandlePlayingState_HavingShips_IsNotClearToAddShips() {
        let system = MockGameManagerSystem_HandlePlayingState_NotClear(asteroidCreator: asteroidCreator,
                                                                       alienCreator: alienCreator,
                                                                       shipCreator: shipCreator,
                                                                       size: CGSize(width: 1024, height: 768),
                                                                       scene: scene, randomness: Randomness.initialize(with: 1),
                                                                       scaleManager: MockScaleManager())
        appStateComponent.numShips = 1
        system.continueOrEnd(appStateComponent: appStateComponent, entity: Entity())
        XCTAssertEqual(system.isClearToAddSpaceshipCalled, true)

        class MockGameManagerSystem_HandlePlayingState_NotClear: GameplayManagerSystem {
            var isClearToAddSpaceshipCalled = false

            override func isClearToAddSpaceship(at position: CGPoint) -> Bool {
                isClearToAddSpaceshipCalled = true
                return false
            }
        }
    }

    func test_HandlePlayingState_NoShips() {
        let appStateComponent = AppStateComponent(gameSize: .zero,
                                                  numShips: 0,
                                                  level: 1,
                                                  score: 0,
                                                  appState: .playing,
                                                  shipControlsState: .showingButtons,
                                                  randomness: Randomness.initialize(with: 1))
        let entity = Entity(named: "currentState")
        system.continueOrEnd(appStateComponent: appStateComponent, entity: entity)
        XCTAssertNotNil(entity[TransitionAppStateComponent.self])
    }

    func test_HandleGameState_NoShips_Playing() {
        let system = MockGameManagerSystem_NoShips_Playing(asteroidCreator: asteroidCreator,
                                                           alienCreator: alienCreator,
                                                           shipCreator: shipCreator,
                                                           size: CGSize(width: 1024, height: 768),
                                                           scene: scene, randomness: Randomness.initialize(with: 1),
                                                           scaleManager: MockScaleManager())
        engine.add(system: system, priority: 1)
        // need to look at this function's logic
        system.handleGameState(appStateComponent: AppStateComponent(gameSize: .zero,
                                                                    numShips: 1,
                                                                    level: 1,
                                                                    score: 0,
                                                                    appState: .playing,
                                                                    shipControlsState: .showingButtons,
                                                                    randomness: Randomness.initialize(with: 1)),
                               entity: Entity(),
                               time: 1.0)
        XCTAssertTrue(system.handlePlayingStateCalled)

        class MockGameManagerSystem_NoShips_Playing: GameplayManagerSystem {
            var handlePlayingStateCalled = false

            override func continueOrEnd(appStateComponent: AppStateComponent, entity: Entity) {
                handlePlayingStateCalled = true
            }
        }
    }

    func test_HandleAlienAppearances() {
        appStateComponent.alienNextAppearance = 1.0
        system.handleAlienAppearances(appStateComponent: appStateComponent, time: 1.0)
        XCTAssertTrue(alienCreator.createAliensCalled)
    }

    func test_HandleGameState_NoAsteroidsTorpedoes() {
        // need to look at this function's logic
        let system = MockGameManagerSystem_NoAsteroidsTorpedoes(asteroidCreator: asteroidCreator,
                                                                alienCreator: alienCreator,
                                                                shipCreator: shipCreator,
                                                                size: CGSize(width: 1024, height: 768),
                                                                scene: scene, randomness: Randomness.initialize(with: 1),
                                                                scaleManager: MockScaleManager())
        engine.add(system: system, priority: 1)
        let shipEntity = Entity(named: .player)
                .add(component: PositionComponent(x: 0, y: 0, z: .ship))
                .add(component: ShipComponent())
        try? engine.add(entity: shipEntity)
        engine.add(system: system, priority: 1)
        //
        system.handleGameState(appStateComponent: AppStateComponent(gameSize: .zero,
                                                                    numShips: 1,
                                                                    level: 1,
                                                                    score: 0,
                                                                    appState: .playing,
                                                                    shipControlsState: .showingButtons,
                                                                    randomness: Randomness.initialize(with: 1)),
                               entity: shipEntity,
                               time: 1.0)
        XCTAssertTrue(system.goToNextLevelCalled)

        class MockGameManagerSystem_NoAsteroidsTorpedoes: GameplayManagerSystem {
            var goToNextLevelCalled = false

            override func goToNextLevel(appStateComponent: AppStateComponent, entity: Entity) {
                goToNextLevelCalled = true
            }
        }
    }
}
