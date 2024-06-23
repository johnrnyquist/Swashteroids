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
@testable import Swash
@testable import Swashteroids

class PickTargetSystemTests: XCTestCase {
    var system: PickTargetSystem!
    let shipNodes = NodeList()

    override func setUp() {
        super.setUp()
        system = PickTargetSystem()
        system.shipNodes = shipNodes
        let shipNode = ShipNode()
        let shipComponent = ShipComponent()
        let shipPosition = PositionComponent(x: 0, y: 0, z: .ship, rotationDegrees: 0)
        shipNode.components = [
            ShipComponent.name: shipComponent,
            PositionComponent.name: shipPosition,
        ]
        let shipEntity = Entity()
                .add(component: shipComponent)
                .add(component: shipPosition)
        shipNode.entity = shipEntity
    }

    override func tearDown() {
        system = nil
        super.tearDown()
    }

    func test_pickTarget_soldier() throws {
        // ARRANGE
        let alienComponent = AlienComponent(cast: .soldier, scoreValue: 50)
        let position = PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0)
        let velocity = VelocityComponent(velocityX: 0, velocityY: 0)
        let entity = Entity()
        // ACT
        system.pickTarget(entity: entity, alienComponent: alienComponent, position: position, velocity: velocity)
        // ASSERT
//        XCTAssertNil(alienComponent.targetedEntity)
    }

    func test_pickTarget_noTarget_onlyShip() throws {
        // ARRANGE
        let system = PickTargetSystem()
        system.shipNodes = shipNodes
//        let soldier = AlienComponent(cast: .soldier, reactionTime: 0.4, scoreValue: 50)
        let position = PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0)
        // ACT
//        system.pickTarget(alienComponent: soldier, position: position)
        // ASSERT
//        XCTAssertNotNil(soldier.targetedEntity)
//        XCTAssertEqual(shipEntity, soldier.targetedEntity)
    }

    func test_pickTarget_closestAsteroid() throws {
        // ARRANGE
        let system = PickTargetSystem()
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
//        let soldier = AlienComponent(cast: .soldier, reactionTime: 0.4, scoreValue: 50)
        let position = PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0)
        // ACT
//        system.pickTarget(alienComponent: soldier, position: position)
        // ASSERT
//        XCTAssertNotNil(soldier.targetedEntity)
//        XCTAssertEqual(asteroidEntity, soldier.targetedEntity)
    }

    func test_pickTarget_ship() throws {
        // ARRANGE
        let system = PickTargetSystem()
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
//        let soldier = AlienComponent(cast: .soldier, reactionTime: 0.4, scoreValue: 50)
        let position = PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0)
        // ACT
//        system.pickTarget(alienComponent: soldier, position: position)
        // ASSERT
//        XCTAssertNotNil(soldier.targetedEntity)
//        XCTAssertEqual(shipEntity, soldier.targetedEntity)
    }

    func test_findClosestEntity_to_in() {
        // Create some entities with positions
        let entity1 = Entity()
        entity1.add(component: PositionComponent(x: 0, y: 0, z: 0))
        let entity2 = Entity()
        entity1.add(component: PositionComponent(x: 10, y: 10, z: 0))
        let entity3 = Entity()
        entity1.add(component: PositionComponent(x: 5, y: 5, z: 0))
        let entitiesWithPositions
            = [(entity1, CGPoint(x: 0, y: 0)),
               (entity2, CGPoint(x: 10, y: 10)),
               (entity3, CGPoint(x: 5, y: 5))]
        // Call the method to test
        let closestEntity
            = system.findClosestEntity(to: CGPoint(x: 6, y: 6), in: entitiesWithPositions)
        // Assert that the closest entity is the correct one
        XCTAssertEqual(closestEntity, entity3, "The closest entity was not correctly identified.")
    }

    func test_findClosestObject_to_in() {
        // Create some entities with positions
        let entity1 = Entity()
        entity1.add(component: PositionComponent(x: 0, y: 0, z: 0))
        let entity2 = Entity()
        entity2.add(component: PositionComponent(x: 10, y: 10, z: 0))
        let entity3 = Entity()
        entity3.add(component: PositionComponent(x: 5, y: 5, z: 0))
        let entities = [entity1, entity2, entity3]
        // Call the method to test
//        let closestEntity
//            = system.findClosestObject(to: CGPoint(x: 6, y: 6), in: entities)
        // Assert that the closest entity is the correct one
//        XCTAssertEqual(closestEntity, entity3, "The closest entity was not correctly identified.")
    }

    func test_findClosestEntity_to_node() {
        // Create some nodes with entities and positions
        let entity1 = Entity()
        let entity2 = Entity()
        let entity3 = Entity()
        entity1.add(component: PositionComponent(x: 0, y: 0, z: 0))
        entity2.add(component: PositionComponent(x: 10, y: 10, z: 0))
        entity3.add(component: PositionComponent(x: 5, y: 5, z: 0))
        let node1 = Node()
        let node2 = Node()
        let node3 = Node()
        node1.entity = entity1
        node2.entity = entity2
        node3.entity = entity3
        node1.next = node2
        node2.next = node3
        let closestEntity = system.findClosestEntity(to: CGPoint(x: 6, y: 6), node: node1)
        XCTAssertEqual(closestEntity, entity3, "The closest entity was not correctly identified.")
    }
}
    
    
