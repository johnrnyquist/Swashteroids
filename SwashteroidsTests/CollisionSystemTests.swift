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
    var creator: MockCreator!
    var engine: Engine!
    var shipEntity: Entity!
    var asteroidEntity: Entity!
    var alienEntity: Entity!
    var torpedoEntity_player: Entity!
    var torpedoEntity_alien: Entity!
    var torpedoPowerUpEntity: Entity!
    var hyperspacePowerUpEntity: Entity!
    var appStateEntity: Entity!
    var appStateComponent: AppStateComponent!

    override func setUpWithError() throws {
        creator = MockCreator()
        engine = Engine()
        appStateComponent = AppStateComponent(gameSize: .zero,
                                              numShips: 1,
                                              level: 1,
                                              score: 0,
                                              appState: .playing,
                                              shipControlsState: .showingButtons,
                                              randomness: Randomness(seed: 1))
        appStateEntity = Entity(named: .appState)
                .add(component: appStateComponent)
        try? engine.add(entity: appStateEntity)
        shipEntity = Entity(named: .player)
                .add(component: ShipComponent())
                .add(component: PositionComponent(x: 0, y: 0, z: .ship, rotationDegrees: 0.0))
                .add(component: VelocityComponent(velocityX: 0.0, velocityY: 0.0, dampening: 0.0, base: 60.0))
                .add(component: CollidableComponent(radius: 25))
                .add(component: DisplayComponent(sknode: SwashSpriteNode()))
        try? engine.add(entity: shipEntity)
        alienEntity = Entity(named: .alienSoldier)
                .add(component: AlienComponent(reactionTime: 1.0, killScore: 350))
                .add(component: PositionComponent(x: 0, y: 0, z: .ship, rotationDegrees: 0.0))
                .add(component: VelocityComponent(velocityX: 0.0, velocityY: 0.0, dampening: 0.0, base: 60.0))
                .add(component: CollidableComponent(radius: 25))
        try? engine.add(entity: alienEntity)
        asteroidEntity = Entity(named: "asteroidEntity")
                .add(component: AsteroidComponent())
                .add(component: CollidableComponent(radius: LARGE_ASTEROID_RADIUS, scaleManager: MockScaleManager()))
                .add(component: PositionComponent(x: 0, y: 0, z: 0))
                .add(component: DisplayComponent(sknode: SKNode()))
                .add(component: VelocityComponent(velocityX: 0, velocityY: 0, dampening: 0, base: 60.0))
        try? engine.add(entity: asteroidEntity)
        torpedoPowerUpEntity = Entity(named: .torpedoPowerUp)
                .add(component: GunPowerUpComponent())
                .add(component: CollidableComponent(radius: POWER_UP_RADIUS, scaleManager: MockScaleManager()))
                .add(component: PositionComponent(x: 0, y: 0, z: 0))
                .add(component: DisplayComponent(sknode: SKNode()))
        try? engine.add(entity: torpedoPowerUpEntity)
        hyperspacePowerUpEntity = Entity(named: .hyperspacePowerUp)
                .add(component: HyperspacePowerUpComponent())
                .add(component: CollidableComponent(radius: 10, scaleManager: MockScaleManager()))
                .add(component: PositionComponent(x: 0, y: 0, z: 0))
                .add(component: DisplayComponent(sknode: SKNode()))
        try? engine.add(entity: hyperspacePowerUpEntity)
        torpedoEntity_player = Entity(named: .torpedo)
                .add(component: TorpedoComponent(lifeRemaining: 1, owner: .player, ownerEntity: shipEntity))
                .add(component: GunPowerUpComponent())
                .add(component: CollidableComponent(radius: 10, scaleManager: MockScaleManager()))
                .add(component: PositionComponent(x: 0, y: 0, z: 0))
                .add(component: DisplayComponent(sknode: SKNode()))
        torpedoEntity_alien = Entity(named: .torpedo)
                .add(component: TorpedoComponent(lifeRemaining: 1, owner: .computerOpponent, ownerEntity: alienEntity))
                .add(component: GunPowerUpComponent())
                .add(component: CollidableComponent(radius: 10, scaleManager: MockScaleManager()))
                .add(component: PositionComponent(x: 0, y: 0, z: 0))
                .add(component: DisplayComponent(sknode: SKNode()))
        try? engine.add(entity: torpedoEntity_player)
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
                                         size: .zero, randomness: Randomness(seed: 1),
                                         scaleManager: MockScaleManager())
        engine.add(system: system, priority: 1)
        // SUT
        system.update(time: 1)
        //
        XCTAssertTrue(system.collisionCheckCalled > 0) //TODO: make better assertion

        class MockCollisionSystem: CollisionSystem {
            var collisionCheckCalled = 0

            override func collisionCheck(nodeA: Node?, nodeB: Node?, action: (Node, Node) -> Void) {
                collisionCheckCalled += 1
            }
        }
    }

    func test_SplitAsteroid() {
        let system = CollisionSystem(creator: creator,
                                     size: .zero,
                                     randomness: Randomness(seed: 2), //2 is the seed for the test
                                     scaleManager: MockScaleManager())
        guard let asteroidEntity else { XCTFail("asteroidEntity is nil!"); return }
        // SUT
        system.splitAsteroid(asteroidEntity: asteroidEntity, splits: 2, level: 1)
        //
        XCTAssertEqual(creator.createAsteroidCalled, 2)
        XCTAssertEqual(creator.createTreasureCalled, true)
        XCTAssertFalse(asteroidEntity.has(componentClassName: CollidableComponent.name))
        XCTAssertTrue(asteroidEntity.has(componentClassName: AudioComponent.name))
        XCTAssertTrue(asteroidEntity.has(componentClassName: DeathThroesComponent.name))
    }

    func test_torpedoAndVehicle_PlayerShootsAlien() {
        let system = CollisionSystem(creator: creator,
                                     size: .zero,
                                     randomness: Randomness(seed: 1),
                                     scaleManager: MockScaleManager())
        engine.add(system: system, priority: 1)
        //
        let torpedoNode = TorpedoCollisionNode()
        for component in torpedoEntity_player.componentClassNameInstanceMap {
            torpedoNode.components[component.key] = component.value
        }
        torpedoNode.entity = torpedoEntity_player
        torpedoEntity_player[TorpedoComponent.self]?.owner = .player
        let alienCollisionNode = AlienCollisionNode()
        for component in alienEntity.componentClassNameInstanceMap {
            alienCollisionNode.components[component.key] = component.value
        }
        alienCollisionNode.entity = alienEntity
        // SUT
        system.torpedoAndVehicle(torpedoNode: torpedoNode, vehicleNode: alienCollisionNode)
        //
        XCTAssertTrue(creator.removeShipCalled)
        XCTAssertEqual(appStateComponent.score, 350)
    }

    func test_torpedoAndVehicle_AlienShootsPlayer() {
        let system = CollisionSystem(creator: creator,
                                     size: .zero,
                                     randomness: Randomness(seed: 1),
                                     scaleManager: MockScaleManager())
        engine.add(system: system, priority: 1)
        //
        appStateComponent.numShips = 1
        let appStateEntity = Entity(named: .appState)
                .add(component: appStateComponent)
        try? engine.add(entity: appStateEntity)
        let torpedoNode = TorpedoCollisionNode()
        for component in torpedoEntity_alien.componentClassNameInstanceMap {
            torpedoNode.components[component.key] = component.value
        }
        torpedoNode.entity = torpedoEntity_alien
        torpedoEntity_alien[TorpedoComponent.self]?.owner = .computerOpponent
        let shipCollisionNode = ShipCollisionNode()
        for component in shipEntity.componentClassNameInstanceMap {
            shipCollisionNode.components[component.key] = component.value
        }
        shipCollisionNode.entity = shipEntity
        // SUT
        system.torpedoAndVehicle(torpedoNode: torpedoNode, vehicleNode: shipCollisionNode)
        //
        XCTAssertTrue(creator.removeShipCalled)
        XCTAssertEqual(appStateComponent.numShips, 0)
    }

    func test_shipAndTorpedoPowerUp() {
        let system = CollisionSystem(creator: creator,
                                     size: .zero,
                                     randomness: Randomness(seed: 1),
                                     scaleManager: MockScaleManager())
        engine.add(system: system, priority: 1)
        let shipCollisionNode = ShipCollisionNode()
        for component in shipEntity.componentClassNameInstanceMap {
            shipCollisionNode.components[component.key] = component.value
        }
        shipCollisionNode.entity = shipEntity
        let torpedoPowerUpNode = GunPowerUpNode()
        for component in torpedoPowerUpEntity.componentClassNameInstanceMap {
            torpedoPowerUpNode.components[component.key] = component.value
        }
        torpedoPowerUpNode.entity = torpedoPowerUpEntity
        // SUT
        system.shipAndTorpedoPowerUp(shipNode: shipCollisionNode, torpedoPowerUpNode: torpedoPowerUpNode)
        //
        XCTAssertTrue(shipEntity.has(componentClassName: GunComponent.name))
        XCTAssertTrue(shipEntity.has(componentClassName: AudioComponent.name))
        XCTAssertNil(engine.findEntity(named: .torpedoPowerUp))
    }

    func test_shipAndHyperspacePowerUp() {
        let system = CollisionSystem(creator: creator,
                                     size: .zero,
                                     randomness: Randomness(seed: 1),
                                     scaleManager: MockScaleManager())
        engine.add(system: system, priority: 1)
        let shipCollisionNode: Node = ShipCollisionNode()
        for component in shipEntity.componentClassNameInstanceMap {
            shipCollisionNode.components[component.key] = component.value
        }
        shipCollisionNode.entity = shipEntity
        let hyperspacePowerUp: Node = HyperspacePowerUpNode()
        for component in hyperspacePowerUpEntity.componentClassNameInstanceMap {
            hyperspacePowerUp.components[component.key] = component.value
        }
        hyperspacePowerUp.entity = hyperspacePowerUpEntity
        // SUT
        system.shipAndHyperspacePowerUp(shipNode: shipCollisionNode, hyperspace: hyperspacePowerUp)
        //
        XCTAssertTrue(shipEntity.has(componentClassName: HyperspaceDriveComponent.name))
        XCTAssertTrue(shipEntity.has(componentClassName: AudioComponent.name))
        XCTAssertNil(engine.findEntity(named: .hyperspacePowerUp))
    }

    func test_torpedoesAndAsteroids() {
        let system = MockCollisionSystem(creator: creator,
                                         size: .zero, randomness: Randomness(seed: 1),
                                         scaleManager: MockScaleManager())
        engine.add(system: system, priority: 1)
        let torpedoNode = GunPowerUpNode()
        for component in torpedoEntity_player.componentClassNameInstanceMap {
            torpedoNode.components[component.key] = component.value
        }
        torpedoNode.entity = torpedoEntity_player
        let asteroidNode = AsteroidCollisionNode()
        for component in asteroidEntity.componentClassNameInstanceMap {
            asteroidNode.components[component.key] = component.value
        }
        asteroidNode.entity = asteroidEntity
        let appState = Entity(named: .appState)
                .add(component: AppStateComponent(gameSize: .zero,
                                                  numShips: 1,
                                                  level: 1,
                                                  score: 0,
                                                  appState: .playing,
                                                  shipControlsState: .showingButtons,
                                                  randomness: Randomness(seed: 1)))
        try? engine.add(entity: appState)
        // SUT
        system.torpedoesAndAsteroids(torpedoNode: torpedoNode, asteroidNode: asteroidNode)
        //
        XCTAssertTrue(system.splitAsteroidCalled)
        XCTAssertNil(engine.findEntity(named: .torpedo))

        class MockCollisionSystem: CollisionSystem {
            var splitAsteroidCalled = false

            override func splitAsteroid(asteroidEntity: Entity, splits: Int = 2, level: Int) {
                splitAsteroidCalled = true
            }
        }
    }

    func test_vehiclesAndAsteroids_Player() {
        let system = MockCollisionSystem(creator: creator,
                                         size: .zero, randomness: Randomness(seed: 1),
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
        //TODO: this is no longer a decent test
        system.vehiclesAndAsteroids(vehicleNode: shipCollisionNode, asteroidNode: asteroidCollisionNode)
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

    class MockCreator: AsteroidCreator & ShipCreator & ShipButtonControlsManager & TreasureCreator {
        //MARK: - ShipButtonControlsManager
        var removeShipControlButtonsCalled = false
        var createShipControlButtonsCalled = false
        var enableShipControlButtonsCalled = false
        var showFireButtonCalled = false
        var showHyperspaceButtonCalled = false
        var createTreasureCalled = false

        func createTreasure(positionComponent: PositionComponent) {
            createTreasureCalled = true
        }

        func removeShipControlButtons() {
            removeShipControlButtonsCalled = true
        }

        func createShipControlButtons() {
            createShipControlButtonsCalled = true
        }

        func enableShipControlButtons() {
            enableShipControlButtonsCalled = true
        }

        func showFireButton() {
            showFireButtonCalled = true
        }

        func showHyperspaceButton() {
            showHyperspaceButtonCalled = true
        }

        //MARK: - AsteroidCreator
        var createAsteroidCalled = 0

        func createAsteroid(radius: Double, x: Double, y: Double, level: Int) {
            createAsteroidCalled += 1
        }

        //MARK: ShipCreator
        var createShipCalled = false
        var removeShipCalled = false

        func createShip(_ state: AppStateComponent) {
            createShipCalled = true
        }

        func destroy(ship: Entity) {
            removeShipCalled = true
        }
    }

    class MockScaleManager: ScaleManaging {
        var SCALE_FACTOR: CGFloat { 1.0 }
    }
}

extension CollisionSystemTests.MockCreator {}
