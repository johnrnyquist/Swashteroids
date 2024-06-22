//
//  AlienSoldierSystemTests.swift
//  SwashteroidsTests
//
//  Created by John Nyquist on 6/9/24.
//

import Foundation
import XCTest
@testable import Swashteroids
@testable import Swash

class AlienSystemTests: XCTestCase {
    var system: AlienSystem!

    override func setUp() {
        super.setUp()
        system = AlienSystem()
    }

    override func tearDown() {
        system = nil
        super.tearDown()
    }
    
    func test_updateAlienReactionTime_enoughToReact() {
        // ARRANGE
        let alienComponent = AlienComponent(cast: .worker, reactionTime: 0.4, scoreValue: 50)
        // ACT
        system.updateAlienReactionTime(alienComponent: alienComponent, time: 0.2)
        system.updateAlienReactionTime(alienComponent: alienComponent, time: 0.2)
        // ASSERT
        XCTAssertEqual(alienComponent.timeSinceLastReaction, 0.0)
    }
    
    func test_updateAlienReactionTime_notEnoughToReact() {
        // ARRANGE
        let alienComponent = AlienComponent(cast: .worker, reactionTime: 0.4, scoreValue: 50)
        // ACT
        system.updateAlienReactionTime(alienComponent: alienComponent, time: 0.1)
        system.updateAlienReactionTime(alienComponent: alienComponent, time: 0.1)
        // ASSERT
        XCTAssertEqual(alienComponent.timeSinceLastReaction, 0.2)
    }

    func test_HasReachedDestination() {
        // Test when endDestination.x is positive
        XCTAssertTrue(system.hasReachedDestination(5.0, CGPoint(x: 4.0, y: 0.0)))
        XCTAssertFalse(system.hasReachedDestination(3.0, CGPoint(x: 4.0, y: 0.0)))
        // Test when endDestination.x is negative
        XCTAssertTrue(system.hasReachedDestination(-7.0, CGPoint(x: -6.0, y: 0.0)))
        XCTAssertFalse(system.hasReachedDestination(-3.0, CGPoint(x: -4.0, y: 0.0)))
        // Test when endDestination.x is zero
        XCTAssertTrue(system.hasReachedDestination(0.0, CGPoint(x: 0.0, y: 0.0)))
    }

    func test_moveTowardTarget() {
        // Create a PositionComponent and VelocityComponent
        let position = PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0)
        let velocity = VelocityComponent(velocityX: 10, velocityY: 10)
        // Define a target point
        let target = CGPoint(x: 100, y: 100)
        // Call the method to test
        system.moveTowardTarget(position, velocity, target)
        // Assert that the position and velocity have been updated correctly
        XCTAssertEqual(velocity.x, 3.452669830012439)
        XCTAssertEqual(velocity.y, 3.4526698300124394)
        XCTAssertEqual(position.rotationRadians, 0.7853981633974483)
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
        let closestEntity
            = system.findClosestObject(to: CGPoint(x: 6, y: 6), in: entities)
        // Assert that the closest entity is the correct one
        XCTAssertEqual(closestEntity, entity3, "The closest entity was not correctly identified.")
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
    
    
