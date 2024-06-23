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
    var alienEntity: Entity!
    var appStateComponent: AppStateComponent!
    var appStateEntity: Entity!
    var asteroidEntity: Entity!
    var engine: Engine!
    var hyperspacePowerUpEntity: Entity!
    var shipEntity: Entity!
    var torpedoEntity_alien: Entity!
    var torpedoEntity_player: Entity!
    var torpedoPowerUpEntity: Entity!
    var treasureEntity: Entity!
    var system: CollisionSystem!
    var shipButtonControlsCreator: MockShipButtonControlsCreator!
    var shipCreator: MockShipCreator!
    var asteroidCreator: MockAsteroidCreator!

    override func setUpWithError() throws {
        engine = Engine()
        appStateComponent = AppStateComponent(gameConfig: GameConfig(gameSize: .zero), randomness: Randomness.initialize(with: 1))
        appStateComponent.numShips = 1
        appStateComponent.appState = .playing
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
                .add(component: AlienComponent(cast: .soldier, scoreValue: 350))
                .add(component: PositionComponent(x: 0, y: 0, z: .ship, rotationDegrees: 0.0))
                .add(component: VelocityComponent(velocityX: 0.0, velocityY: 0.0, dampening: 0.0, base: 60.0))
                .add(component: CollidableComponent(radius: 25))
        try? engine.add(entity: alienEntity)
        asteroidEntity = Entity(named: "asteroidEntity")
                .add(component: AsteroidComponent(size: .large))
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
        treasureEntity = Entity(named: "treasure_1")
                .add(component: TreasureComponent(value: 1))
                .add(component: CollidableComponent(radius: 10, scaleManager: MockScaleManager()))
                .add(component: PositionComponent(x: 0, y: 0, z: 0))
        shipButtonControlsCreator = MockShipButtonControlsCreator()
        shipCreator = MockShipCreator()
        asteroidCreator = MockAsteroidCreator()
        system = CollisionSystem(shipCreator: shipCreator,
                                 asteroidCreator: asteroidCreator,
                                 shipButtonControlsCreator: shipButtonControlsCreator,
                                 size: .zero,
                                 randomness: Randomness.initialize(with: 1),
                                 scaleManager: MockScaleManager())
    }

    override func tearDownWithError() throws {
        engine = nil
        shipEntity = nil
        asteroidEntity = nil
        torpedoPowerUpEntity = nil
        hyperspacePowerUpEntity = nil
    }

    func test_Update() {
        let system = MockCollisionSystem(shipCreator: shipCreator,
                                         asteroidCreator: asteroidCreator, 
                                         shipButtonControlsCreator: shipButtonControlsCreator,
                                         size: .zero,
                                         randomness: Randomness.initialize(with: 1))
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

    // TODO: Move to test sweet for SplitAsteroidSystem
//    func test_SplitAsteroid() {
//        let system = CollisionSystem(creator: creator,
//                                     size: .zero,
//                                     randomness: Randomness(seed: 2), //2 is the seed for the test
//                                     scaleManager: MockScaleManager())
//        guard let asteroidEntity else { XCTFail("asteroidEntity is nil!"); return }
//        // SUT
//        system.splitAsteroid(asteroidEntity: asteroidEntity, splits: 2, level: 1)
//        //
//        XCTAssertEqual(creator.createAsteroidCalled, 2)
//        XCTAssertEqual(creator.createTreasureCalled, true)
//        XCTAssertFalse(asteroidEntity.has(componentClassName: CollidableComponent.name))
//        XCTAssertTrue(asteroidEntity.has(componentClassName: AudioComponent.name))
//        XCTAssertTrue(asteroidEntity.has(componentClassName: DeathThroesComponent.name))
//    }
    func test_torpedoAndVehicle_PlayerShootsAlien() {
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
        XCTAssertTrue(shipCreator.destroyCalled)
        XCTAssertEqual(appStateComponent.score, 350)
    }

    func test_torpedoAndVehicle_AlienShootsPlayer() {
        engine.add(system: system, priority: 1)
        //
        appStateComponent.numShips = 1
        let appStateEntity = Entity(named: .appState)
                .add(component: appStateComponent)
        engine.replace(entity: appStateEntity)
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
        XCTAssertTrue(shipCreator.destroyCalled)
        XCTAssertEqual(appStateComponent.numShips, 0)
    }

    func test_shipAndTorpedoPowerUp() {
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
        let appStateComponent = AppStateComponent(gameConfig: GameConfig(gameSize: .zero), randomness: Randomness.initialize(with: 1))
        appStateComponent.numShips = 1
        appStateComponent.appState = .playing
        let appState = Entity(named: .appState)
                .add(component: appStateComponent)
        engine.replace(entity: appState)
        // SUT
        system.torpedoesAndAsteroids(torpedoNode: torpedoNode, asteroidNode: asteroidNode)
        //
        XCTAssertTrue(asteroidNode.entity!.has(componentClass: SplitAsteroidComponent.self))
        XCTAssertNil(engine.findEntity(named: .torpedo))
    }

    func test_vehiclesAndAsteroids_Player() {
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
        XCTAssertTrue(asteroidCollisionNode.entity!.has(componentClass: SplitAsteroidComponent.self))
        XCTAssertTrue(appStateComponent.numShips == 0)
    }

    func test_vehiclesAndTreasures() {
        engine.add(system: system, priority: 1)
        let shipCollisionNode = ShipCollisionNode()
        for component in shipEntity.componentClassNameInstanceMap {
            shipCollisionNode.components[component.key] = component.value
        }
        shipCollisionNode.entity = shipEntity
        let treasure = TreasureCollisionNode()
        for component in treasureEntity.componentClassNameInstanceMap {
            treasure.components[component.key] = component.value
        }
        treasure.entity = treasureEntity
        // SUT
        system.vehiclesAndTreasures(vehicleNode: shipCollisionNode, treasureNode: treasure)
        //
        XCTAssertNil(engine.findEntity(named: "treasure_1"))
    }

    func test_shipsAndAliens() {
        engine.add(system: system, priority: 1)
        let shipCollisionNode = ShipCollisionNode()
        for component in shipEntity.componentClassNameInstanceMap {
            shipCollisionNode.components[component.key] = component.value
        }
        shipCollisionNode.entity = shipEntity
        let alienCollisionNode = AlienCollisionNode()
        for component in alienEntity.componentClassNameInstanceMap {
            alienCollisionNode.components[component.key] = component.value
        }
        alienCollisionNode.entity = alienEntity
        // SUT
        system.shipsAndAliens(shipNode: shipCollisionNode, alienNode: alienCollisionNode)
        //
        XCTAssertTrue(shipCreator.destroyCalled)
        XCTAssertTrue(appStateComponent.numShips == 0)
    }

    func test_collisionCheck() {
        let nodeA = ShipCollisionNode()
        for component in shipEntity.componentClassNameInstanceMap {
            nodeA.components[component.key] = component.value
        }
        nodeA.entity = shipEntity
        let nodeB = AsteroidCollisionNode()
        for component in asteroidEntity.componentClassNameInstanceMap {
            nodeB.components[component.key] = component.value
        }
        nodeB.entity = asteroidEntity
        var result = false
        // SUT
        system.collisionCheck(nodeA: nodeA, nodeB: nodeB) { _, _ in
            result = true
        }
        //
        XCTAssertTrue(result)
    }
}
