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
    var asteroidNodes: NodeList!
    var treasureNodes: NodeList!
    var treasureEntity: Entity!
    var asteroidEntity: Entity!

    override func setUpWithError() throws {
        asteroidNodes = NodeList()
        treasureNodes = NodeList()
        let asteroidNode = AsteroidCollisionNode()
        let treasureNode = TreasureCollisionNode()
        asteroidNodes.add(node: asteroidNode)
        treasureNodes.add(node: treasureNode)
        treasureEntity = Entity()
        asteroidEntity = Entity()
        asteroidNode.entity = treasureEntity
        treasureNode.entity = asteroidEntity
    }

    override func tearDownWithError() throws {
        asteroidNodes = nil
        treasureNodes = nil
        treasureEntity = nil
        asteroidEntity = nil
    }

    func test_pickTarget_noTarget() throws {
        let system = TestableAlienWorkerSystem(randomness: Random())
        system.asteroidNodes = asteroidNodes
        system.treasureNodes = treasureNodes
        let workerComponent = AlienComponent(reactionTime: 0.4, killScore: 50)
        let position = PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0)
        system.pickTarget(alienComponent: workerComponent, position: position)
        XCTAssertNotNil(workerComponent.targetedEntity)
    }

    func test_moveTowardTarget() throws {
        let system = AlienWorkerSystem(randomness: Random())
        let position = PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0)
        let velocity = VelocityComponent(velocityX: 10, velocityY: 10)
        system.moveTowardTarget(position, velocity, CGPoint(x: 100, y: 100))
        XCTAssertEqual(velocity.x, 3.452669830012439)
        XCTAssertEqual(velocity.y, 3.4526698300124394)
        XCTAssertEqual(position.rotationRadians, 0.7853981633974483)
    }

    class Random: Randomizing {
        func nextDouble() -> Double { 0 }

        func nextInt(upTo max: Int) -> Int { 0 }

        func nextInt(from min: Int, upTo max: Int) -> Int { 0 }

        func nextInt(from min: Int, through max: Int) -> Int { 0 }

        func nextDouble(from min: Double, through max: Double) -> Double { 0 }

        func nextBool() -> Bool { false }
    }

    class TestableAlienWorkerSystem: AlienWorkerSystem {
        override func findClosestEntity(to position: CGPoint, node: Node?) -> Entity? {
            node?.entity
        }
    }
}
