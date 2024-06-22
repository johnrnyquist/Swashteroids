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

final class AlienSoldierSystemTests: XCTestCase {
    var shipNodes: NodeList!
    var shipEntity: Entity!
    var alienEntity: Entity!
    var alienNode: AlienSoldierNode!

    override func setUpWithError() throws {
        shipNodes = NodeList()
        let shipNode = ShipNode()
        shipNodes.add(node: shipNode)
        shipEntity = Entity()
                .add(component: PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0))
        shipNode.entity = shipEntity
        // alienEntity
        let positionComponent = PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0)
        let velocityComponent = VelocityComponent(velocityX: 0, velocityY: 0)
        let alienComponent = AlienComponent(cast: .soldier, reactionTime: 0.4, scoreValue: 50)
        let alienSoldierComponent = AlienSoldierComponent()
        alienComponent.targetedEntity = shipEntity
        alienEntity = Entity()
                .add(component: alienSoldierComponent)
                .add(component: alienComponent)
                .add(component: positionComponent)
                .add(component: velocityComponent)
        alienEntity.add(component: GunComponent(offsetX: 0,
                                                offsetY: 0,
                                                minimumShotInterval: 0,
                                                torpedoLifetime: 0,
                                                ownerType: .computerOpponent,
                                                ownerEntity: alienEntity,
                                                numTorpedoes: 0))
        // alienNode
        alienNode = AlienSoldierNode()
        alienNode.entity = alienEntity
        alienNode.components = [
            AlienSoldierComponent.name: alienSoldierComponent,
            AlienComponent.name: alienComponent,
            PositionComponent.name: positionComponent,
            VelocityComponent.name: velocityComponent,
        ]
    }

    override func tearDownWithError() throws {
        shipNodes = nil
        shipEntity = nil
    }

    func test_pickTarget_noTarget_noShip() throws {
        // ARRANGE
        let system = AlienSoldierSystem()
        let soldier = AlienComponent(cast: .soldier, reactionTime: 0.4, scoreValue: 50)
        let position = PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0)
        // ACT
        system.pickTarget(alienComponent: soldier, position: position)
        // ASSERT
        XCTAssertNil(soldier.targetedEntity)
    }

    func test_pickTarget_noTarget_onlyShip() throws {
        // ARRANGE
        let system = AlienSoldierSystem()
        system.shipEntity = shipEntity
        let soldier = AlienComponent(cast: .soldier, reactionTime: 0.4, scoreValue: 50)
        let position = PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0)
        // ACT
        system.pickTarget(alienComponent: soldier, position: position)
        // ASSERT
        XCTAssertNotNil(soldier.targetedEntity)
        XCTAssertEqual(shipEntity, soldier.targetedEntity)
    }

    func test_pickTarget_closestAsteroid() throws {
        // ARRANGE
        let system = AlienSoldierSystem()
        let asteroidComponent = AsteroidComponent(size: .large)
        let positionComponent = PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0)
        let collidableComponent = CollidableComponent(radius: 10)
        let velocityComponent = VelocityComponent(velocityX: 0, velocityY: 0)
        let asteroidEntity = Entity()
                .add(component: asteroidComponent)
                .add(component: positionComponent)
                .add(component: collidableComponent)
                .add(component: velocityComponent)
        let asteroidNode = AsteroidCollisionNode()
        asteroidNode.components = [
            AsteroidComponent.name: asteroidComponent,
            PositionComponent.name: positionComponent,
            CollidableComponent.name: collidableComponent,
            VelocityComponent.name: velocityComponent,
        ]
        asteroidNode.entity = asteroidEntity
        system.asteroidNodes = NodeList()
        system.asteroidNodes?.add(node: asteroidNode)
        system.shipEntity = shipEntity
        let soldier = AlienComponent(cast: .soldier, reactionTime: 0.4, scoreValue: 50)
        let position = PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0)
        // ACT
        system.pickTarget(alienComponent: soldier, position: position)
        // ASSERT
        XCTAssertNotNil(soldier.targetedEntity)
        XCTAssertEqual(asteroidEntity, soldier.targetedEntity)
    }

    func test_pickTarget_ship() throws {
        // ARRANGE
        let system = AlienSoldierSystem()
        let asteroidComponent = AsteroidComponent(size: .large)
        let positionComponent = PositionComponent(x: 1000, y: 0, z: .asteroids, rotationDegrees: 0)
        let collidableComponent = CollidableComponent(radius: 10)
        let velocityComponent = VelocityComponent(velocityX: 0, velocityY: 0)
        let asteroid = Entity()
                .add(component: asteroidComponent)
                .add(component: positionComponent)
                .add(component: collidableComponent)
                .add(component: velocityComponent)
        let asteroidNode = AsteroidCollisionNode()
        asteroidNode.components = [
            AsteroidComponent.name: asteroidComponent,
            PositionComponent.name: positionComponent,
            CollidableComponent.name: collidableComponent,
            VelocityComponent.name: velocityComponent,
        ]
        asteroidNode.entity = asteroid
        system.asteroidNodes = NodeList()
        system.asteroidNodes?.add(node: asteroidNode)
        system.shipEntity = shipEntity
        let soldier = AlienComponent(cast: .soldier, reactionTime: 0.4, scoreValue: 50)
        let position = PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0)
        // ACT
        system.pickTarget(alienComponent: soldier, position: position)
        // ASSERT
        XCTAssertNotNil(soldier.targetedEntity)
        XCTAssertEqual(shipEntity, soldier.targetedEntity)
    }

    func test_moveTowardTarget() throws {
        // ARRANGE
        let system = AlienSoldierSystem()
        let position = PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0)
        let velocity = VelocityComponent(velocityX: 10, velocityY: 10)
        // ACT
        system.moveTowardTarget(position, velocity, CGPoint(x: 100, y: 100))
        // ASSERT
        XCTAssertEqual(velocity.x, 3.452669830012439)
        XCTAssertEqual(velocity.y, 3.4526698300124394)
        XCTAssertEqual(position.rotationRadians, 0.7853981633974483)
    }

    func test_updateNode_playerDead() throws {
        let system = Testable_AlienSoldierSystem_playerDead()
        let alienComponent = alienEntity.find(componentClass: AlienComponent.self)!
        let positionComponent = alienEntity.find(componentClass: PositionComponent.self)!
        let velocityComponent = alienEntity.find(componentClass: VelocityComponent.self)!
        // ACT
        system.updateNode(node: alienNode, time: 1)
        // ASSERT
        XCTAssertEqual(alienComponent.timeSinceLastReaction, 0)
        XCTAssertFalse(alienEntity.has(componentClass: GunComponent.self))
        XCTAssertEqual(positionComponent.rotationRadians, CGFloat.pi)
        XCTAssertEqual(velocityComponent.linearVelocity, .zero)
    }

    func test_updateNode_targetDead() throws {
        let system = Testable_AlienSoldierSystem_targetDead()
        let alienComponent = alienEntity.find(componentClass: AlienComponent.self)!
        alienComponent.targetedEntity = shipEntity
        // ACT
        system.updateNode(node: alienNode, time: 1)
        // ASSERT
        XCTAssertEqual(alienComponent.timeSinceLastReaction, 0)
        XCTAssertNil(alienComponent.targetedEntity)
    }

    func test_updateNode_playerDead_noGun() throws {
        let system = Testable_AlienSoldierSystem_playerDead()
        let soldier = AlienComponent(cast: .soldier, reactionTime: 0.4, scoreValue: 50)
        let alienComponent = AlienComponent(cast: .soldier, reactionTime: 0.4, scoreValue: 50)
        let positionComponent = PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0)
        let velocityComponent = VelocityComponent(velocityX: 0, velocityY: 0)
        let alienNode = AlienSoldierNode()
        let alienEntity = Entity()
        alienNode.entity = alienEntity
        alienNode.components = [
            AlienSoldierComponent.name: soldier,
            AlienComponent.name: alienComponent,
            PositionComponent.name: positionComponent,
            VelocityComponent.name: velocityComponent,
        ]
        // ACT
        system.updateNode(node: alienNode, time: 1)
        // ASSERT
        XCTAssertEqual(alienComponent.timeSinceLastReaction, 0)
    }

    func test_updateNode_playerAlive() throws {
        let system = Testable_AlienSoldierSystem_playerAlive()
        let alienComponent = alienEntity.find(componentClass: AlienComponent.self)!
        let velocityComponent = alienEntity.find(componentClass: VelocityComponent.self)!
        // ACT
        system.updateNode(node: alienNode, time: 1)
        // ASSERT
        XCTAssertEqual(alienComponent.timeSinceLastReaction, 0)
        XCTAssertEqual(velocityComponent.linearVelocity, .zero)
        XCTAssertTrue(system.pickTargetCalled)
        XCTAssertTrue(system.moveTowardsTargetCalled)
    }

    // MARK: - Testable classes
    class Testable_AlienSoldierSystem_playerAlive: AlienSoldierSystem {
        var pickTargetCalled = false
        var moveTowardsTargetCalled = false
        var targetedEntity: Entity?
        override var playerAlive: Bool { true }

        override func pickTarget(alienComponent: AlienComponent, position: PositionComponent) {
            pickTargetCalled = true
            targetedEntity = Entity()
                    .add(component: PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0))
            alienComponent.targetedEntity = targetedEntity
        }

        override func moveTowardTarget(_ position: PositionComponent, _ velocity: VelocityComponent, _ target: CGPoint) {
            moveTowardsTargetCalled = true
        }
    }

    class Testable_AlienSoldierSystem_playerDead: AlienSoldierSystem {
        override var playerAlive: Bool { false }
    }

    class Testable_AlienSoldierSystem_targetDead: AlienSoldierSystem {
        override func isTargetDead(_ entity: Entity?) -> Bool { true }
    }
}
