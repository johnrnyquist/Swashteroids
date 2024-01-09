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

final class FlipSystemTests: XCTestCase {
    var system: FlipSystem!

    override func setUpWithError() throws {
        system = FlipSystem()
    }

    override func tearDownWithError() throws {
        system = nil
    }

    func test_Init() throws {
        XCTAssertTrue(system.nodeClass == FlipNode.self)
        XCTAssertNotNil(system.nodeUpdateFunction)
    }

    func test_UpdateNode() throws {
        let node = FlipNode()
        let initialRotation = 10.0
        let position = PositionComponent(x: 0, y: 0, z: .ship, rotationDegrees: initialRotation)
        let flip = FlipComponent.shared
        let entity = Entity(named: .flipButton)
                .add(component: flip)
        node.entity = entity
        node.components[PositionComponent.name] = position
        node.components[FlipComponent.name] = flip
        if system.nodeUpdateFunction == nil {
            XCTFail("nodeUpdateFunction is nil")
        } else {
            system.nodeUpdateFunction!(node, 1)
        }
        XCTAssertEqual(position.rotationDegrees, initialRotation + 180.0)
        // More of an integration test here as I'm not mocking the accessing 
        // of the entity and the removal of the component.
        XCTAssertNil(entity[FlipComponent.self])
    }
}
