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

class FiringSystemTests: XCTestCase {
    var system: TestableFiringSystem!
    var torpedoCreator: MockTorpedoCreator!
    var engine: Engine!
    var entity: Entity!
    var gun: GunComponent!

    override func setUpWithError() throws {
        torpedoCreator = MockTorpedoCreator()
        system = TestableFiringSystem(torpedoCreator: torpedoCreator)
        engine = Engine()
        engine.add(system: system, priority: 1)
        entity = Entity(named: "test")
        gun = GunComponent(offsetX: 0,
                           offsetY: 0,
                           minimumShotInterval: 0.0,
                           torpedoLifetime: 0,
                           torpedoColor: .torpedo,
                           ownerType: .player,
                           ownerName: entity.name,
                           numTorpedoes: 20)
        entity
                .add(component: VelocityComponent(velocityX: 0, velocityY: 0, base: 60.0))
                .add(component: PositionComponent(x: 0, y: 0, z: .player))
                .add(component: gun)
                .add(component: FireDownComponent.shared)
        engine.add(entity: entity)
        let appStateComponent = GameStateComponent(config: GameConfig(gameSize: .zero))
        let appState = Entity(named: .appState)
                .add(component: appStateComponent)
        engine.add(entity: appState)
    }

    override func tearDownWithError() throws {
        engine = nil
        system = nil
        torpedoCreator = nil
        entity = nil
        gun = nil
    }

    func test_Fire() {
        system.update(time: 1.0)
        XCTAssertTrue(torpedoCreator.fired)
        XCTAssertEqual(gun.numTorpedoes, 19)
        XCTAssertTrue(system.updateNodeCalled)
    }

    func test_Fire_notYetTimeToFire() {
        gun.minimumShotInterval = 2.0
        gun.timeSinceLastShot = 0.0
        system.update(time: 1.0)
        XCTAssertFalse(torpedoCreator.fired)
        XCTAssertEqual(gun.numTorpedoes, 20)
        XCTAssertTrue(system.updateNodeCalled)
    }

    class TestableFiringSystem: FiringSystem {
        var updateNodeCalled = false

        override func updateNode(node: Node, time: TimeInterval) {
            updateNodeCalled = true
            super.updateNode(node: node, time: time)
        }
    }

    class MockTorpedoCreator: TorpedoCreatorUseCase {
        var fired = false

        func createTorpedo(_ gunComponent: GunComponent, _ parentPosition: PositionComponent, _ parentVelocity: VelocityComponent) {
            fired = true
        }
    }
}
