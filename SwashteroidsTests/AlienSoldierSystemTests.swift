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

    override func setUpWithError() throws {
        shipNodes = NodeList()
        let shipNode = ShipNode()
        shipNodes.add(node: shipNode)
        shipEntity = Entity()
        shipNode.entity = shipEntity
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
        system.shipNodes = shipNodes
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
        system.shipNodes = shipNodes
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
        system.shipNodes = shipNodes
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
}
