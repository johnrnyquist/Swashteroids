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

final class ThrustSystemTests: XCTestCase {
    var system: ThrustSystem!

    override func setUpWithError() throws {
        system = ThrustSystem()
    }

    override func tearDownWithError() throws {
        system = nil
    }

    func test_Init() throws {
        XCTAssertTrue(system.nodeClass == ThrustNode.self)
        XCTAssertNotNil(system.nodeUpdateFunction)
    }

    func test_UpdateNode() throws {
        let rotation = Double.pi/4.0
        let position = PositionComponent(x: 0, y: 0, z: .ship, rotationDegrees: rotation)
        let applythrust = ApplyThrustComponent.shared
        let motion = MotionComponent(velocityX: 0.0, velocityY: 0.0)
        let motionControls = MotionControlsComponent(accelerationRate: 10.0,
                                                     rotationRate: 0.0,
                                                     scaleManager: MockScaleManager())
        let warpdrive = WarpDriveComponent()
        let node = ThrustNode()
        node.components[PositionComponent.name] = position
        node.components[ApplyThrustComponent.name] = applythrust
        node.components[MotionComponent.name] = motion
        node.components[MotionControlsComponent.name] = motionControls
        node.components[WarpDriveComponent.name] = warpdrive
        node.components[PositionComponent.name] = position
        if system.nodeUpdateFunction == nil {
            XCTFail("nodeUpdateFunction is nil")
        } else {
            system.nodeUpdateFunction!(node, 1)
        }
        XCTAssertEqual(motion.velocity.x, 9.999060498015504)
        XCTAssertEqual(motion.velocity.y, 0.13707354604707475)
    }

    class MockScaleManager: ScaleManaging {
        var SCALE_FACTOR: CGFloat { 1.0 }
    }
}