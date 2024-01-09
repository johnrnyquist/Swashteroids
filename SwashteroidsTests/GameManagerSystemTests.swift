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

final class GameManagerSystemTests: XCTestCase {
    var creator: MockCreator!
    var engine: Engine!
    var scene: SKScene!

    override func setUpWithError() throws {
        engine = Engine()
        creator = MockCreator()
        scene = SKScene()
    }

    override func tearDownWithError() throws {
        scene = nil
        creator = nil
        engine = nil
    }

    func test_IsClearToAddSpaceship() {
        let system = GameplayManagerSystem(creator: creator,
                                           size: CGSize(width: 1024, height: 768),
                                           scene: scene,
                                           scaleManager: MockScaleManager())
        engine.add(system: system, priority: 1)
        let asteroid = Entity(named: "asteroid")
                .add(component: AsteroidComponent())
                .add(component: CollisionComponent(radius: LARGE_ASTEROID_RADIUS,
                                                   scaleManager: MockScaleManager()))
                .add(component: PositionComponent(x: 0, y: 0, z: .asteroids))
                .add(component: VelocityComponent(velocityX: 0, velocityY: 0))
        try? engine.add(entity: asteroid)
        let suggestedShipLocation = CGPoint(x: 100, y: 100)
        let result = system.isClearToAddSpaceship(at: suggestedShipLocation)
        XCTAssertTrue(result)
    }

    func test_IsNotClearToAddSpaceship() {
        let system = GameplayManagerSystem(creator: creator,
                                           size: CGSize(width: 1024, height: 768),
                                           scene: scene,
                                           scaleManager: MockScaleManager())
        engine.add(system: system, priority: 1)
        let asteroid = Entity(named: "asteroid")
                .add(component: AsteroidComponent())
                .add(component: CollisionComponent(radius: LARGE_ASTEROID_RADIUS,
                                                   scaleManager: MockScaleManager()))
                .add(component: PositionComponent(x: 0, y: 0, z: .asteroids))
                .add(component: VelocityComponent(velocityX: 0, velocityY: 0))
        try? engine.add(entity: asteroid)
        let suggestedShipLocation = CGPoint(x: 0, y: 0)
        let result = system.isClearToAddSpaceship(at: suggestedShipLocation)
        XCTAssertFalse(result)
    }

    func test_CreatePowerUps() {
        let system = GameplayManagerSystem(creator: creator,
                                           size: CGSize(width: 1024, height: 768),
                                           scene: scene,
                                           scaleManager: MockScaleManager())
        engine.add(system: system, priority: 1)
        system.createPowerUps(level: 1)
        XCTAssertTrue(creator.createHyperspacePowerUpLevelCalled)
        XCTAssertTrue(creator.createPlasmaTorpedoesPowerUpLevelCalled)
    }

    func test_CreateAsteroids() {
        let system = GameplayManagerSystem(creator: creator,
                                           size: CGSize(width: 1024, height: 768),
                                           scene: scene,
                                           scaleManager: MockScaleManager())
        engine.add(system: system, priority: 1)
        system.createAsteroids(count: 2, avoiding: .zero, level: 1)
        XCTAssertEqual(creator.createAsteroidCalled, 2)
    }

    func test_GoToNextLevel() {
        let system = MockGameManagerSystem_GoToNextLevel(creator: creator,
                                                         size: CGSize(width: 1024, height: 768),
                                                         scene: scene,
                                                         scaleManager: MockScaleManager())
        let shipEntity = Entity(named: .ship)
                .add(component: PositionComponent(x: 0, y: 0, z: .ship))
                .add(component: ShipComponent())
        try? engine.add(entity: shipEntity)
        engine.add(system: system, priority: 1)
        let appStateComponent = AppStateComponent(size: .zero,
                                                  ships: 1,
                                                  level: 1,
                                                  score: 0,
                                                  appState: .playing,
                                                  shipControlsState: .showingButtons)
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

    func test_HandlePlayingState_HavingShips_IsClearToAddShips() {
        let system = MockGameManagerSystem_HandlePlayingState(creator: creator,
                                                              size: CGSize(width: 1024, height: 768),
                                                              scene: scene,
                                                              scaleManager: MockScaleManager())
        let appStateComponent = AppStateComponent(size: .zero,
                                                  ships: 1,
                                                  level: 1,
                                                  score: 0,
                                                  appState: .playing,
                                                  shipControlsState: .showingButtons)
        system.handlePlayingState(appStateComponent: appStateComponent, entity: Entity())
        XCTAssertEqual(system.isClearToAddSpaceshipCalled, true)
        XCTAssertEqual(system.createPowerUpsCalled, true)

        class MockGameManagerSystem_HandlePlayingState: GameplayManagerSystem {
            var isClearToAddSpaceshipCalled = false
            var createPowerUpsCalled = false

            override func isClearToAddSpaceship(at position: CGPoint) -> Bool {
                isClearToAddSpaceshipCalled = true
                return true
            }

            override func createPowerUps(level: Int) {
                createPowerUpsCalled = true
            }
        }
    }

    func test_HandlePlayingState_HavingShips_IsNotClearToAddShips() {
        let system = MockGameManagerSystem_HandlePlayingState_NotClear(creator: creator,
                                                                       size: CGSize(width: 1024, height: 768),
                                                                       scene: scene,
                                                                       scaleManager: MockScaleManager())
        let appStateComponent = AppStateComponent(size: .zero,
                                                  ships: 1,
                                                  level: 1,
                                                  score: 0,
                                                  appState: .playing,
                                                  shipControlsState: .showingButtons)
        system.handlePlayingState(appStateComponent: appStateComponent, entity: Entity())
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
        let system = GameplayManagerSystem(creator: creator,
                                           size: CGSize(width: 1024, height: 768),
                                           scene: scene,
                                           scaleManager: MockScaleManager())
        let appStateComponent = AppStateComponent(size: .zero,
                                                  ships: 0,
                                                  level: 1,
                                                  score: 0,
                                                  appState: .playing,
                                                  shipControlsState: .showingButtons)
        let entity = Entity(named: "currentState")
        system.handlePlayingState(appStateComponent: appStateComponent, entity: entity)
        XCTAssertNotNil(entity[TransitionAppStateComponent.self])
    }

    func test_HandleGameState_NoShips_Playing() {
        let system = MockGameManagerSystem_NoShips_Playing(creator: creator,
                                                           size: CGSize(width: 1024, height: 768),
                                                           scene: scene,
                                                           scaleManager: MockScaleManager())
        engine.add(system: system, priority: 1)
        // need to look at this function's logic
        system.handleGameState(appStateComponent: AppStateComponent(size: .zero,
                                                                    ships: 1,
                                                                    level: 1,
                                                                    score: 0,
                                                                    appState: .playing,
                                                                    shipControlsState: .showingButtons),
                               entity: Entity())
        XCTAssertTrue(system.handlePlayingStateCalled)

        class MockGameManagerSystem_NoShips_Playing: GameplayManagerSystem {
            var handlePlayingStateCalled = false

            override func handlePlayingState(appStateComponent: AppStateComponent, entity: Entity) {
                handlePlayingStateCalled = true
            }
        }
    }

    func test_HandleGameState_NoAsteroidsTorpedoes() {
        // need to look at this function's logic
        let system = MockGameManagerSystem_NoAsteroidsTorpedoes(creator: creator,
                                                                size: CGSize(width: 1024, height: 768),
                                                                scene: scene,
                                                                scaleManager: MockScaleManager())
        engine.add(system: system, priority: 1)
        let shipEntity = Entity(named: .ship)
                .add(component: PositionComponent(x: 0, y: 0, z: .ship))
                .add(component: ShipComponent())
        try? engine.add(entity: shipEntity)
        engine.add(system: system, priority: 1)
        //
        system.handleGameState(appStateComponent: AppStateComponent(size: .zero,
                                                                    ships: 1,
                                                                    level: 1,
                                                                    score: 0,
                                                                    appState: .playing,
                                                                    shipControlsState: .showingButtons),
                               entity: shipEntity)
        XCTAssertTrue(system.goToNextLevelCalled)

        class MockGameManagerSystem_NoAsteroidsTorpedoes: GameplayManagerSystem {
            var goToNextLevelCalled = false

            override func goToNextLevel(appStateComponent: AppStateComponent, entity: Entity) {
                goToNextLevelCalled = true
            }
        }
    }

    class MockScaleManager: ScaleManaging {
        var SCALE_FACTOR: CGFloat { 1.0 }
    }

    class MockCreator: PowerUpCreator & ShipCreator & AsteroidCreator & TorpedoCreator & AlienCreator {
        var createAlienCalled = false
        var createPlasmaTorpedoesPowerUpLevelCalled = false
        var createHyperspacePowerUpLevelCalled = false
        var createAsteroidCalled = 0

        func createAlien() {
            createAlienCalled = true
        }

        func createHyperspacePowerUp(level: Int) {
            createHyperspacePowerUpLevelCalled = true
        }

        func createHyperspacePowerUp(level: Int, radius: Double) {
        }

        func createPlasmaTorpedoesPowerUp(level: Int) {
            createPlasmaTorpedoesPowerUpLevelCalled = true
        }

        func createPlasmaTorpedoesPowerUp(level: Int, radius: Double) {
        }

        func createShip(_ state: AppStateComponent) {
        }

        func destroy(ship: Entity) {
        }

        func createAsteroid(radius: Double, x: Double, y: Double, level: Int) {
            createAsteroidCalled += 1
        }

        func createPlasmaTorpedo(_ gunComponent: GunComponent, _ parentPosition: PositionComponent, _ parentVelocity: VelocityComponent) {
        }
    }
}
