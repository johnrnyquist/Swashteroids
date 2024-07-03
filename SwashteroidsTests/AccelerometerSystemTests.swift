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

final class AccelerometerSystemTests: XCTestCase {
    var system: AccelerometerSystem!

    override func setUpWithError() throws {
        system = AccelerometerSystem()
    }

    override func tearDownWithError() throws {
        system = nil
    }

    func test_Init() throws {
        XCTAssertTrue(system.nodeClass == AccelerometerNode.self)
        XCTAssertNotNil(system.nodeUpdateFunction)
    }

    func test_RotateIsDown() throws {
        let node = AccelerometerNode()
        let accelerometer = AccelerometerComponent()
        let input = AccelerometerComponent.shared
        input.rotate = (true, 1.0)
        let position = PositionComponent(x: 0, y: 0, z: .ship, rotationDegrees: 0.0)
        let motionControls = MovementRateComponent(accelerationRate: 1.0,
                                                     rotationRate: 1.0,
                                                     scaleManager: MockScaleManager())
        node.components[AccelerometerComponent.name] = accelerometer
        node.components[AccelerometerComponent.name] = input
        node.components[MovementRateComponent.name] = motionControls
        node.components[PositionComponent.name] = position
        if system.nodeUpdateFunction == nil {
            XCTFail("nodeUpdateFunction is nil")
        } else {
            system.nodeUpdateFunction!(node, 1)
        }
        XCTAssertEqual(position.rotationDegrees, 0.05)
    }
    
    func test_RotateIsNotDown() throws {
        let node = AccelerometerNode()
        let accelerometer = AccelerometerComponent()
        let input = AccelerometerComponent.shared
        input.rotate = (false, 0.0)
        let position = PositionComponent(x: 0, y: 0, z: .ship, rotationDegrees: 0.0)
        let motionControls = MovementRateComponent(accelerationRate: 1.0,
                                                     rotationRate: 1.0,
                                                     scaleManager: MockScaleManager_halfSize())
        node.components[AccelerometerComponent.name] = accelerometer
        node.components[AccelerometerComponent.name] = input
        node.components[MovementRateComponent.name] = motionControls
        node.components[PositionComponent.name] = position
        if system.nodeUpdateFunction == nil {
            XCTFail("nodeUpdateFunction is nil")
        } else {
            system.nodeUpdateFunction!(node, 1)
        }
        XCTAssertEqual(position.rotationDegrees, 0.0)
    }
}
