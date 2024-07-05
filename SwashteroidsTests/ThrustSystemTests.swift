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
        let position = PositionComponent(x: 0, y: 0, z: .player, rotationDegrees: rotation)
        let applythrust = ApplyThrustComponent.shared
        let motion = VelocityComponent(velocityX: 0.0, velocityY: 0.0, base: 60.0)
        let motionControls = MovementRateComponent(accelerationRate: 10.0,
                                                     rotationRate: 0.0,
                                                     scaleManager: MockScaleManager())
        let warpdrive = WarpDriveComponent()
        let node = ThrustNode()
        node.components[PositionComponent.name] = position
        node.components[ApplyThrustComponent.name] = applythrust
        node.components[VelocityComponent.name] = motion
        node.components[MovementRateComponent.name] = motionControls
        node.components[WarpDriveComponent.name] = warpdrive
        node.components[PositionComponent.name] = position
        if system.nodeUpdateFunction == nil {
            XCTFail("nodeUpdateFunction is nil")
        } else {
            system.nodeUpdateFunction!(node, 1)
        }
        XCTAssertEqual(motion.linearVelocity.x, 9.999060498015504)
        XCTAssertEqual(motion.linearVelocity.y, 0.13707354604707475)
    }
}