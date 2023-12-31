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

final class RightSystemTests: XCTestCase {
    var system: RightSystem!

    override func setUpWithError() throws {
        system = RightSystem()
    }

    override func tearDownWithError() throws {
        system = nil
    }

    func test_Init() throws {
        XCTAssertTrue(system.nodeClass == RightNode.self)
        XCTAssertNotNil(system.nodeUpdateFunction)
    }

    func test_UpdateNode() throws {
        let node = RightNode()
        let left = RightComponent.shared
        let position = PositionComponent(x: 0, y: 0, z: .ship, rotationDegrees: 0.0)
        let motionControls = MotionControlsComponent(accelerationRate: 0.0,
                                                     rotationRate: 1.0)
        node.components[RightComponent.name] = left
        node.components[MotionControlsComponent.name] = motionControls
        node.components[PositionComponent.name] = position
        if system.nodeUpdateFunction == nil {
            XCTFail("nodeUpdateFunction is nil")
        } else {
            system.nodeUpdateFunction!(node, 1)
        }
        XCTAssertEqual(position.rotationDegrees, -0.0175)
    }
}