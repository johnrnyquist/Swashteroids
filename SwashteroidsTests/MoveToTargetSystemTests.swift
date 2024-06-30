//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import Foundation
import XCTest
@testable import Swash
@testable import Swashteroids

class MoveToTargetSystemTests: XCTestCase {
    var system: MoveToTargetSystem!

    override func setUp() {
        super.setUp()
        system = MoveToTargetSystem()
    }

    override func tearDown() {
        system = nil
        super.tearDown()
    }

    func test_moveTowardTarget() {
        // Create a PositionComponent and VelocityComponent
        let position = PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0)
        let velocity = VelocityComponent(velocityX: 10, velocityY: 10)
        // Define a target point
        let target = CGPoint(x: 100, y: 100)
        // Call the method to test
        system.moveTowardTarget(cast: .soldier, position: position, velocity: velocity, targetPoint: target)
        // Assert that the position and velocity have been updated correctly
        XCTAssertEqual(velocity.x, 4.867760418618789)
        XCTAssertEqual(velocity.y, 0.3831010533586185)
        XCTAssertEqual(position.rotationRadians, 0.07853981633974483)
    }
}
