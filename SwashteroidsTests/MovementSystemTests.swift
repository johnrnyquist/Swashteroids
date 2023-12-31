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

final class MovementSystemTests: XCTestCase {
    var system: MovementSystem!
    var size: CGSize!

    override func setUpWithError() throws {
        size = CGSize(width: 1024.0, height: 768.0)
        system = MovementSystem(size: size)
    }

    override func tearDownWithError() throws {
        system = nil
        size = nil
    }

    func test_Init() throws {
        XCTAssertTrue(system.nodeClass == MovementNode.self)
        XCTAssertNotNil(system.nodeUpdateFunction)
    }

    class MockScaleManager: ScaleManaging {
        var SCALE_FACTOR: CGFloat { 0.5 }
    }

    func test_UpdatePosition() throws {
        let node = MovementNode()
        let positionComponent = PositionComponent(x: 0, y: 0, z: .ship)
        let motionComponent = MotionComponent(velocityX: 1.0, 
                                              velocityY: 2.0, 
                                              angularVelocity: 0.0, 
                                              dampening: 0.0,
                                              scaleManager: MockScaleManager())
        node.components[PositionComponent.name] = positionComponent
        node.components[MotionComponent.name] = motionComponent
        system.updateNode(node: node, time: 1)
        XCTAssertEqual(positionComponent.x, 0.5)  
        XCTAssertEqual(positionComponent.y, 1.0)  
    }

    func test_UpdateNodeWrapBoundsXLeft() throws {
        let node = MovementNode()
        let positionComponent = PositionComponent(x: 0.0, y: 0.0, z: .ship)
        let motionComponent = MotionComponent(velocityX: -1.0, 
                                              velocityY: 0.0, 
                                              angularVelocity: 0.0, 
                                              dampening: 0.0,
                                              scaleManager: MockScaleManager())
        node.components[PositionComponent.name] = positionComponent
        node.components[MotionComponent.name] = motionComponent
        system.updateNode(node: node, time: 1)
        XCTAssertEqual(positionComponent.x, 1023.5)
        XCTAssertEqual(positionComponent.y, 0.0)
    }

    func test_UpdateNodeWrapBoundsYDown() throws {
        let node = MovementNode()
        let positionComponent = PositionComponent(x: 0.0, y: 0.0, z: .ship)
        let motionComponent = MotionComponent(velocityX: 0.0, 
                                              velocityY: -1.0, 
                                              angularVelocity: 0.0, 
                                              dampening: 0.0,
                                              scaleManager: MockScaleManager())
        node.components[PositionComponent.name] = positionComponent
        node.components[MotionComponent.name] = motionComponent
        system.updateNode(node: node, time: 1)
        XCTAssertEqual(positionComponent.x, 0.0)
        XCTAssertEqual(positionComponent.y, 767.5) 
    }

    func test_UpdateNodeWrapBoundsXRight() throws {
        let node = MovementNode()
        let positionComponent = PositionComponent(x: size.width, y: 0.0, z: .ship)
        let motionComponent = MotionComponent(velocityX: 1.0, 
                                              velocityY: 0.0, 
                                              angularVelocity: 0.0, 
                                              dampening: 0.0,
                                              scaleManager: MockScaleManager())
        node.components[PositionComponent.name] = positionComponent
        node.components[MotionComponent.name] = motionComponent
        system.updateNode(node: node, time: 1)
        XCTAssertEqual(positionComponent.x, 0.5) 
        XCTAssertEqual(positionComponent.y, 0.0)
    }

    func test_UpdateNodeWrapBoundsYUp() throws {
        let node = MovementNode()
        let positionComponent = PositionComponent(x: 0.0, y: size.height, z: .ship)
        let motionComponent = MotionComponent(velocityX: 0.0, 
                                              velocityY: 1.0, 
                                              angularVelocity: 0.0, 
                                              dampening: 0.0, 
                                              scaleManager: MockScaleManager())
        node.components[PositionComponent.name] = positionComponent
        node.components[MotionComponent.name] = motionComponent
        system.updateNode(node: node, time: 1)
        XCTAssertEqual(positionComponent.x, 0.0)
        XCTAssertEqual(positionComponent.y, 0.5) 
    }

    func test_Rotation() throws {
        let node = MovementNode()
        let positionComponent = PositionComponent(x: 0.0, y: 0, z: .ship)
        let motionComponent = MotionComponent(velocityX: 0.0, velocityY: 0, angularVelocity: 1.0, dampening: 0.0)
        node.components[PositionComponent.name] = positionComponent
        node.components[MotionComponent.name] = motionComponent
        system.updateNode(node: node, time: 1)
        XCTAssertEqual(positionComponent.rotation, 1.0)
    }

    func test_DampeningAffectsXandY() throws {
        let node = MovementNode()
        let positionComponent = PositionComponent(x: 0.0, y: 0, z: .ship)
        let motionComponent = MotionComponent(velocityX: 1.0, velocityY: 1.0,
                                              angularVelocity: 1.0, dampening: 0.1)
        node.components[PositionComponent.name] = positionComponent
        node.components[MotionComponent.name] = motionComponent
        system.updateNode(node: node, time: 1)
        system.updateNode(node: node, time: 1)
        XCTAssertLessThan(motionComponent.velocity.x, 2.0)
        XCTAssertLessThan(motionComponent.velocity.y, 2.0)
        XCTAssertLessThan(positionComponent.x, 2.0)
        XCTAssertLessThan(positionComponent.y, 2.0)
        XCTAssertEqual(positionComponent.rotation, 2.0)
    }

    func test_NegVelocityDampeningAffectsXandY() throws {
        let numUpdates = 2
        let time: TimeInterval = 1
        let node = MovementNode()
        let positionComponent = PositionComponent(x: size.width, y: size.height, z: .ship)
        let motionComponent = MotionComponent(velocityX: -1.0, velocityY: -1.0,
                                              angularVelocity: 1.0, dampening: 0.1)
        node.components[PositionComponent.name] = positionComponent
        node.components[MotionComponent.name] = motionComponent
        for _ in 0..<numUpdates {
            system.updateNode(node: node, time: time)
        }
        XCTAssertLessThan(motionComponent.velocity.x, 2.0)
        XCTAssertLessThan(motionComponent.velocity.y, 2.0)
        XCTAssertGreaterThan(positionComponent.x, size.width - Double(numUpdates) * time)
        XCTAssertGreaterThan(positionComponent.y, size.height - Double(numUpdates) * time)
        XCTAssertEqual(positionComponent.rotation, 2.0)
    }
}

