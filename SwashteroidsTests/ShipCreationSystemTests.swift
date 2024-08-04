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

final class ShipCreationSystemTests: XCTestCase {
    var engine: Engine!
    var scene: GameScene!
    var alienCreator: MockAlienCreator!
    var asteroidCreator: MockAsteroidCreator!
    var shipCreator: PlayerCreatorUseCase!
    var system: ShipCreationSystem! //TODO: Set to actual system
    var appStateComponent: GameStateComponent!
    let aliens = NodeList()
    let asteroids = NodeList()
    var players = NodeList()

    override func setUpWithError() throws {
        engine = Engine()
        alienCreator = MockAlienCreator()
        asteroidCreator = MockAsteroidCreator()
        shipCreator = MockPlayerCreator()
        scene = GameScene()
        appStateComponent = GameStateComponent(config: GameConfig(gameSize: .zero))
        appStateComponent.level = 1
        system = ShipCreationSystem(playerCreator: shipCreator, gameSize: .zero)
        system.aliens = aliens
        system.asteroids = asteroids
        system.players = players
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
                .add(component: CollidableComponent(radius: AsteroidSize.large.rawValue,
                                                    scaleManager: MockScaleManager()))
                .add(component: PositionComponent(x: 0, y: 0, z: .asteroids))
                .add(component: VelocityComponent(velocityX: 0, velocityY: 0, base: 60.0))
        engine.add(entity: asteroid)
        let suggestedShipLocation = CGPoint(x: 100, y: 100)
        let result = system.isClearToAddSpaceship(at: suggestedShipLocation)
        XCTAssertTrue(result)
    }

    func test_IsNotClearToAddSpaceship() {
        engine.add(system: system, priority: 1)
        let asteroid = Entity(named: "asteroid")
                .add(component: AsteroidComponent(size: .large))
                .add(component: CollidableComponent(radius: AsteroidSize.large.rawValue,
                                                    scaleManager: MockScaleManager()))
                .add(component: PositionComponent(x: 0, y: 0, z: .asteroids))
                .add(component: VelocityComponent(velocityX: 0, velocityY: 0, base: 60.0))
        engine.add(entity: asteroid)
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

    //TODO: Move to new system
//    func test_CreateAsteroids() {
//        engine.add(system: system, priority: 1)
//        // SUT
//        system.createAsteroids(count: 2, avoiding: .zero, level: 1)
//        // 
//        XCTAssertEqual(asteroidCreator.createAsteroidCalled, 2)
//    }
//
//    func test_GoToNextLevel() {
//        let system = MockGameManagerSystem_GoToNextLevel(asteroidCreator: asteroidCreator,
//                                                         alienCreator: alienCreator,
//                                                         shipCreator: shipCreator,
//                                                         size: CGSize(width: 1024, height: 768),
//                                                         scene: scene, randomness: Randomness.initialize(with: 1),
//                                                         scaleManager: MockScaleManager())
//        let shipEntity = Entity(named: .player)
//                .add(component: PositionComponent(x: 0, y: 0, z: .ship))
//                .add(component: ShipComponent())
//        engine.add(entity: shipEntity)
//        engine.add(system: system, priority: 1)
//        system.goToNextLevel(appStateComponent: appStateComponent, entity: shipEntity)
//        XCTAssertEqual(appStateComponent.level, 2)
//        XCTAssertTrue(system.announceLevelCalled)
//        XCTAssertEqual(system.createAsteroidsCalled, 1)
//
//        class MockGameManagerSystem_GoToNextLevel: GameplayManagerSystem {
//            var announceLevelCalled = false
//            var createAsteroidsCalled = 0
//
//            override func announceLevel(appStateComponent: SwashteroidsStateComponent) {
//                announceLevelCalled = true
//            }
//
//            override func createAsteroids(count: Int, avoiding positionToAvoid: CGPoint, level: Int) {
//                createAsteroidsCalled += 1
//            }
//        }
//    }
    func test_HandlePlayingState_HavingShips_IsClearToAddShips() {
        let system = MockShipCreationSystem_HandlePlayingState(playerCreator: shipCreator, gameSize: .zero)
        engine.add(system: system, priority: 1)
        appStateComponent.gameScreen = .playing
        appStateComponent.numShips = 1
        system.checkForShips(appStateComponent: appStateComponent)
        XCTAssertEqual(system.isClearToAddSpaceshipCalled, true)

        class MockShipCreationSystem_HandlePlayingState: ShipCreationSystem {
            var isClearToAddSpaceshipCalled = false

            override func isClearToAddSpaceship(at position: CGPoint) -> Bool {
                isClearToAddSpaceshipCalled = true
                return true
            }
        }
    }

//    func test_HandlePlayingState_HavingShips_IsNotClearToAddShips() {
//        let system = MockGameManagerSystem_HandlePlayingState_NotClear(asteroidCreator: asteroidCreator,
//                                                                       alienCreator: alienCreator,
//                                                                       shipCreator: shipCreator,
//                                                                       size: CGSize(width: 1024, height: 768),
//                                                                       scene: scene, randomness: Randomness.initialize(with: 1),
//                                                                       scaleManager: MockScaleManager())
//        appStateComponent.numShips = 1
//        system.continueOrEnd(appStateComponent: appStateComponent, entity: Entity())
//        XCTAssertEqual(system.isClearToAddSpaceshipCalled, true)
//
//        class MockGameManagerSystem_HandlePlayingState_NotClear: GameplayManagerSystem {
//            var isClearToAddSpaceshipCalled = false
//
//            override func isClearToAddSpaceship(at position: CGPoint) -> Bool {
//                isClearToAddSpaceshipCalled = true
//                return false
//            }
//        }
//    }

//    func test_HandleGameState_NoShips_Playing() {
//        let system = MockGameManagerSystem_NoShips_Playing(asteroidCreator: asteroidCreator,
//                                                           alienCreator: alienCreator,
//                                                           shipCreator: shipCreator,
//                                                           size: CGSize(width: 1024, height: 768),
//                                                           scene: scene, randomness: Randomness.initialize(with: 1),
//                                                           scaleManager: MockScaleManager())
//        engine.add(system: system, priority: 1)
//        //TODO: need to look at this function's logic
//        let appStateComponent = SwashteroidsStateComponent(config: SwashteroidsConfig(gameSize: .zero))
//        appStateComponent.swashteroidsState = .playing
//        system.handleGameState(appStateComponent: appStateComponent, entity: Entity(), time: 1.0)
//        XCTAssertTrue(system.handlePlayingStateCalled)
//
//        class MockGameManagerSystem_NoShips_Playing: GameplayManagerSystem {
//            var handlePlayingStateCalled = false
//
//            override func continueOrEnd(appStateComponent: SwashteroidsStateComponent, entity: Entity) {
//                handlePlayingStateCalled = true
//            }
//        }
//    }
//    func test_HandleAlienAppearances() {
//        appStateComponent.alienNextAppearance = 1.0
//        system.handleAlienAppearances(appStateComponent: appStateComponent, time: 1.0)
//        XCTAssertTrue(alienCreator.createAliensCalled)
//    }
//    func test_HandleGameState_NoAsteroidsTorpedoes() {
//        // need to look at this function's logic
//        let system = MockGameManagerSystem_NoAsteroidsTorpedoes(asteroidCreator: asteroidCreator,
//                                                                alienCreator: alienCreator,
//                                                                shipCreator: shipCreator,
//                                                                size: CGSize(width: 1024, height: 768),
//                                                                scene: scene, randomness: Randomness.initialize(with: 1),
//                                                                scaleManager: MockScaleManager())
//        engine.add(system: system, priority: 1)
//        let shipEntity = Entity(named: .player)
//                .add(component: PositionComponent(x: 0, y: 0, z: .ship))
//                .add(component: ShipComponent())
//        engine.add(entity: shipEntity)
//        engine.add(system: system, priority: 1)
//        //
//        let appStateComponent = SwashteroidsStateComponent(config: SwashteroidsConfig(gameSize: .zero))
//        appStateComponent.swashteroidsState = .playing
//        appStateComponent.numShips = 1
//        appStateComponent.shipControlsState = .usingScreenControls
//        system.handleGameState(appStateComponent: appStateComponent,
//                               entity: shipEntity,
//                               time: 1.0)
//        XCTAssertTrue(system.goToNextLevelCalled)
//
//        class MockGameManagerSystem_NoAsteroidsTorpedoes: GameplayManagerSystem {
//            var goToNextLevelCalled = false
//
//            override func goToNextLevel(appStateComponent: SwashteroidsStateComponent, entity: Entity) {
//                goToNextLevelCalled = true
//            }
//        }
//    }
}