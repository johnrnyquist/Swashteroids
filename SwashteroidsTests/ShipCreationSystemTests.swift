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
    var shipCreator: PlayerCreatorUseCase!
    var system: ShipCreationSystem! //TODO: Set to actual system
    var appStateComponent: GameStateComponent!

    override func setUpWithError() throws {
        engine = Engine()
        shipCreator = MockPlayerCreator()
        appStateComponent = GameStateComponent(config: GameConfig(gameSize: .zero))
        appStateComponent.level = 1
        system = ShipCreationSystem(playerCreator: shipCreator, gameSize: .zero)
    }

    override func tearDownWithError() throws {
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
        let result = system.isClear(at: suggestedShipLocation)
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
        let result = system.isClear(at: suggestedShipLocation)
        XCTAssertFalse(result)
    }

    func test_HandlePlayingState_HavingShips_IsClearToAddShips() {
        let system = TestableShipCreationSystem_isClearToAddShip(playerCreator: shipCreator, gameSize: .zero)
        engine.add(system: system, priority: 1)
        appStateComponent.gameScreen = .playing
        appStateComponent.numShips = 1
        system.playerCheck(appStateComponent: appStateComponent)
        XCTAssertEqual(system.isClearCalled, true)
    }

    class TestableShipCreationSystem_isClearToAddShip: ShipCreationSystem {
        var isClearCalled = false

        override func isClear(at position: CGPoint) -> Bool {
            isClearCalled = true
            return true
        }
    }
}
