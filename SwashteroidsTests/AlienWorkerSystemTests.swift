//
//  AlienWorkerSystemTests.swift
//  SwashteroidsTests
//
//  Created by John Nyquist on 6/9/24.
//

import XCTest
@testable import Swashteroids
@testable import Swash

final class AlienWorkerSystemTests: XCTestCase {
    var targetableNodes: NodeList!
    var targetableEntity: Entity!

    override func setUpWithError() throws {
        targetableNodes = NodeList()
        let targetableNode = AlienWorkerTargetNode()
        targetableNodes.add(node: targetableNode)
        targetableEntity = Entity(named: "targetableEntity")
        targetableNode.entity = targetableEntity
    }

    override func tearDownWithError() throws {
        targetableNodes = nil
        targetableEntity = nil
    }

    func test_pickTarget_noTarget() throws {
        let system = TestableAlienWorkerSystem(randomness: MockRandom())
        system.targetableNodes = targetableNodes
        let workerComponent = AlienComponent(reactionTime: 0.4, killScore: 50)
        let position = PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0)
        system.pickTarget(alienComponent: workerComponent, position: position)
        XCTAssertNotNil(workerComponent.targetedEntity)
    }

    func test_moveTowardTarget() throws {
        let system = AlienWorkerSystem(randomness: MockRandom())
        let position = PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0)
        let velocity = VelocityComponent(velocityX: 10, velocityY: 10)
        system.moveTowardTarget(position, velocity, CGPoint(x: 100, y: 100))
        XCTAssertEqual(velocity.x, 3.452669830012439)
        XCTAssertEqual(velocity.y, 3.4526698300124394)
        XCTAssertEqual(position.rotationRadians, 0.7853981633974483)
    }

    class TestableAlienWorkerSystem: AlienWorkerSystem {
        override func findClosestEntity(to position: CGPoint, node: Node?) -> Entity? {
            node?.entity
        }
    }
}
