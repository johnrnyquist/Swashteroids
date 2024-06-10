//
//  AlienSoldierSystemTests.swift
//  SwashteroidsTests
//
//  Created by John Nyquist on 6/9/24.
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

    func test_pickTarget_noTarget() throws {
        let system = AlienSoldierSystem()
        system.shipNodes = shipNodes
        let soldier = AlienComponent(reactionTime: 0.4, killScore: 50)
        let position = PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0)
        system.pickTarget(alienComponent: soldier, position: position)
        XCTAssertNotNil(soldier.targetingEntity)
        XCTAssertEqual(shipEntity, soldier.targetingEntity)
    }

    func test_moveTowardTarget() throws {
        let system = AlienSoldierSystem()
        let position = PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0)
        let velocity = VelocityComponent(velocityX: 10, velocityY: 10)
        system.moveTowardTarget(position, velocity, CGPoint(x: 100, y: 100))
        XCTAssertEqual(velocity.x, 3.452669830012439)
        XCTAssertEqual(velocity.y, 3.4526698300124394)
        XCTAssertEqual(position.rotationRadians, 0.7853981633974483)
    }
}
