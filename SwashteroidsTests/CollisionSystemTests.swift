//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import SpriteKit
import XCTest
@testable import Swashteroids
@testable import Swash

class CollisionSystemTests: XCTestCase {
    var creator: MockAsteroidCreator!
    var engine: Engine!
    var shipEntity: Entity!
    var asteroidEntity: Entity!
    var alienEntity: Entity!
    var torpedoEntity: Entity!
    var torpedoPowerUpEntity: Entity!
    var hyperspacePowerUpEntity: Entity!
    var appStateEntity: Entity!
    var appStateComponent: AppStateComponent!

    override func setUpWithError() throws {
        creator = MockAsteroidCreator()
        engine = Engine()
        appStateComponent = AppStateComponent(size: .zero,
                                              ships: 1,
                                              level: 1,
                                              score: 0,
                                              appState: .playing,
                                              shipControlsState: .showingButtons)
        appStateEntity = Entity(named: .appState)
                .add(component: appStateComponent)
        try? engine.add(entity: appStateEntity)
        shipEntity = Entity(named: .ship)
                .add(component: ShipComponent())
                .add(component: PositionComponent(x: 0, y: 0, z: .ship, rotationDegrees: 0.0))
                .add(component: VelocityComponent(velocityX: 0.0, velocityY: 0.0, dampening: 0.0, base: 60.0))
                .add(component: CollisionComponent(radius: 25))
        try? engine.add(entity: shipEntity)
        alienEntity = Entity(named: .alien)
            .add(component: AlienComponent(reactionTime: 1.0))
                .add(component: PositionComponent(x: 0, y: 0, z: .ship, rotationDegrees: 0.0))
                .add(component: VelocityComponent(velocityX: 0.0, velocityY: 0.0, dampening: 0.0, base: 60.0))
                .add(component: CollisionComponent(radius: 25))
        try? engine.add(entity: alienEntity)
        asteroidEntity = Entity(named: "asteroidEntity")
                .add(component: AsteroidComponent())
                .add(component: CollisionComponent(radius: LARGE_ASTEROID_RADIUS, scaleManager: MockScaleManager()))
                .add(component: PositionComponent(x: 0, y: 0, z: 0))
                .add(component: DisplayComponent(sknode: SKNode()))
                .add(component: VelocityComponent(velocityX: 0, velocityY: 0, dampening: 0, base: 60.0))
        try? engine.add(entity: asteroidEntity)
        torpedoPowerUpEntity = Entity(named: .torpedoPowerUp)
                .add(component: GunPowerUpComponent())
                .add(component: CollisionComponent(radius: POWER_UP_RADIUS, scaleManager: MockScaleManager()))
                .add(component: PositionComponent(x: 0, y: 0, z: 0))
                .add(component: DisplayComponent(sknode: SKNode()))
        try? engine.add(entity: torpedoPowerUpEntity)
        hyperspacePowerUpEntity = Entity(named: .hyperspacePowerUp)
                .add(component: HyperspacePowerUpComponent())
                .add(component: CollisionComponent(radius: 10, scaleManager: MockScaleManager()))
                .add(component: PositionComponent(x: 0, y: 0, z: 0))
                .add(component: DisplayComponent(sknode: SKNode()))
        try? engine.add(entity: hyperspacePowerUpEntity)
        torpedoEntity = Entity(named: "torpedoEnityt")
                .add(component: GunPowerUpComponent())
                .add(component: CollisionComponent(radius: 10, scaleManager: MockScaleManager()))
                .add(component: PositionComponent(x: 0, y: 0, z: 0))
                .add(component: DisplayComponent(sknode: SKNode()))
        try? engine.add(entity: torpedoEntity)
    }

    override func tearDownWithError() throws {
        creator = nil
        engine = nil
        shipEntity = nil
        asteroidEntity = nil
        torpedoPowerUpEntity = nil
        hyperspacePowerUpEntity = nil
    }

    func test_Update() {
        let system = MockCollisionSystem(creator: creator,
                                         size: .zero,
                                         scaleManager: MockScaleManager())
        engine.add(system: system, priority: 1)
        // SUT
        system.update(time: 1)
        //
        XCTAssertTrue(system.shipTorpedoPowerUpCollisionCheckCalled)
        XCTAssertTrue(system.shipHSCollisionCheckCalled)
        XCTAssertTrue(system.torpedoAsteroidCollisionCheckCalled)
        XCTAssertTrue(system.shipAsteroidCollisionCheckCalled)

        class MockCollisionSystem: CollisionSystem {
            var shipTorpedoPowerUpCollisionCheckCalled = false
            var shipHSCollisionCheckCalled = false
            var torpedoAsteroidCollisionCheckCalled = false
            var shipAsteroidCollisionCheckCalled = false

            override func shipTorpedoPowerUpCollisionCheck(shipCollisionNode: Node?, torpedoPowerUpNode: Node?) {
                shipTorpedoPowerUpCollisionCheckCalled = true
            }

            override func shipHyperspacePowerUpCollisionCheck(shipCollisionNode: Node?, hyperspacePowerUpNode: Node?) {
                shipHSCollisionCheckCalled = true
            }

            override func torpedoAsteroidCollisionCheck(torpedoCollisionNode: Node?, asteroidCollisionNode: Node?) {
                torpedoAsteroidCollisionCheckCalled = true
            }

            override func vehicleAsteroidCollisionCheck(node: Node?, asteroidCollisionNode: Node?) {
                shipAsteroidCollisionCheckCalled = true
            }
        }
    }

    func test_SplitAsteroid() {
        let system = CollisionSystem(creator: creator,
                                     size: .zero,
                                     scaleManager: MockScaleManager())
        guard let asteroidEntity else { XCTFail("asteroidEntity is nil!"); return }
        // SUT
        system.splitAsteroid(asteroidEntity: asteroidEntity, splits: 2, level: 1)
        //
        XCTAssertEqual(creator.createAsteroidCalled, 2)
        XCTAssertFalse(asteroidEntity.has(componentClassName: CollisionComponent.name))
        XCTAssertTrue(asteroidEntity.has(componentClassName: AudioComponent.name))
        XCTAssertTrue(asteroidEntity.has(componentClassName: DeathThroesComponent.name))
    }

    func test_ShipTorpedoPowerUpCollisionCheck() {
        let system = CollisionSystem(creator: creator,
                                     size: .zero,
                                     scaleManager: MockScaleManager())
        engine.add(system: system, priority: 1)
        let shipCollisionNode = ShipCollisionNode()
        for component in shipEntity.componentClassNameInstanceMap {
            shipCollisionNode.components[component.key] = component.value
        }
        shipCollisionNode.entity = shipEntity
        let torpedoPowerUpNode = GunSupplierNode()
        for component in torpedoPowerUpEntity.componentClassNameInstanceMap {
            torpedoPowerUpNode.components[component.key] = component.value
        }
        torpedoPowerUpNode.entity = torpedoPowerUpEntity
        // SUT
        system.shipTorpedoPowerUpCollisionCheck(shipCollisionNode: shipCollisionNode,
                                                torpedoPowerUpNode: torpedoPowerUpNode)
        //
        XCTAssertTrue(shipEntity.has(componentClassName: GunComponent.name))
        XCTAssertTrue(shipEntity.has(componentClassName: AudioComponent.name))
        XCTAssertNil(engine.getEntity(named: .torpedoPowerUp))
    }

    func test_ShipHyperspacePowerUpCollisionCheck() {
        let system = CollisionSystem(creator: creator,
                                     size: .zero,
                                     scaleManager: MockScaleManager())
        engine.add(system: system, priority: 1)
        let shipCollisionNode: Node = ShipCollisionNode()
        for component in shipEntity.componentClassNameInstanceMap {
            shipCollisionNode.components[component.key] = component.value
        }
        shipCollisionNode.entity = shipEntity
        let hsPowerUpNode: Node = GunSupplierNode()
        for component in hyperspacePowerUpEntity.componentClassNameInstanceMap {
            hsPowerUpNode.components[component.key] = component.value
        }
        hsPowerUpNode.entity = hyperspacePowerUpEntity
        // SUT
        system.shipHyperspacePowerUpCollisionCheck(shipCollisionNode: shipCollisionNode,
                                                   hyperspacePowerUpNode: hsPowerUpNode)
        //
        XCTAssertTrue(shipEntity.has(componentClassName: HyperspaceEngineComponent.name))
        XCTAssertTrue(shipEntity.has(componentClassName: AudioComponent.name))
        XCTAssertNil(engine.getEntity(named: "hsPowerUp"))
    }

    func test_TorpedoAsteroidCollisionCheck() {
        let system = MockCollisionSystem(creator: creator,
                                         size: .zero,
                                         scaleManager: MockScaleManager())
        engine.add(system: system, priority: 1)
        let torpedoNode = GunSupplierNode()
        for component in torpedoEntity.componentClassNameInstanceMap {
            torpedoNode.components[component.key] = component.value
        }
        torpedoNode.entity = torpedoEntity
        let asteroidNode = AsteroidCollisionNode()
        for component in asteroidEntity.componentClassNameInstanceMap {
            asteroidNode.components[component.key] = component.value
        }
        asteroidNode.entity = asteroidEntity
        let appState = Entity(named: .appState)
                .add(component: AppStateComponent(
                    size: .zero,
                    ships: 1,
                    level: 1,
                    score: 0,
                    appState: .playing,
                    shipControlsState: .showingButtons))
        try? engine.add(entity: appState)
        // SUT
        system.torpedoAsteroidCollisionCheck(torpedoCollisionNode: torpedoNode, asteroidCollisionNode: asteroidNode)
        //
        XCTAssertTrue(system.splitAsteroidCalled)
        XCTAssertNil(engine.getEntity(named: "torpedo"))

        class MockCollisionSystem: CollisionSystem {
            var splitAsteroidCalled = false

            override func splitAsteroid(asteroidEntity: Entity, splits: Int = 2, level: Int) {
                splitAsteroidCalled = true
            }
        }
    }

    func test_ShipAsteroidCollisionCheck() {
        let system = MockCollisionSystem(creator: creator,
                                         size: .zero,
                                         scaleManager: MockScaleManager())
        engine.add(system: system, priority: 1)
        let shipCollisionNode = ShipCollisionNode()
        shipCollisionNode.entity = shipEntity
        for component in shipEntity.componentClassNameInstanceMap {
            shipCollisionNode.components[component.key] = component.value
        }
        let asteroidCollisionNode = AsteroidCollisionNode()
        for component in asteroidEntity.componentClassNameInstanceMap {
            asteroidCollisionNode.components[component.key] = component.value
        }
        asteroidCollisionNode.entity = asteroidEntity
        // SUT
        system.vehicleAsteroidCollisionCheck(node: shipCollisionNode,
                                             asteroidCollisionNode: asteroidCollisionNode)
        //
        XCTAssertTrue(system.splitAsteroidCalled)
        XCTAssertTrue(appStateComponent.numShips == 0)

        class MockCollisionSystem: CollisionSystem {
            var splitAsteroidCalled = false

            override func splitAsteroid(asteroidEntity: Entity, splits: Int = 2, level: Int) {
                splitAsteroidCalled = true
            }
        }
    }

    class MockAsteroidCreator: AsteroidCreator & ShipCreator {
        var createAsteroidCalled = 0
        var createShipCalled = false
        var removeShipCalled = false

        func createShip(_ state: AppStateComponent) {
            createShipCalled = true
        }

        func destroy(ship: Entity) {
            removeShipCalled = true
        }

        func createAsteroid(radius: Double, x: Double, y: Double, level: Int) {
            createAsteroidCalled += 1
        }
    }

    class MockScaleManager: ScaleManaging {
        var SCALE_FACTOR: CGFloat { 1.0 }
    }
}
