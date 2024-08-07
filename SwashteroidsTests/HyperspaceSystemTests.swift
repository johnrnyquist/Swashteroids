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

final class HyperspaceSystemTests: XCTestCase {
    var system: HyperspaceJumpSystem!

    override func setUpWithError() throws {
        system = HyperspaceJumpSystem()
    }

    override func tearDownWithError() throws {
        system = nil
    }

    func test_Init() throws {
        XCTAssertTrue(system.nodeClass == DoHyperspaceJumpNode.self)
        XCTAssertNotNil(system.nodeUpdateFunction)
    }

    func test_UpdateNode() throws {
        let entity = Entity()
        let node = DoHyperspaceJumpNode()
        node.entity = entity
        let hyperEngine = HyperspaceDriveComponent(jumps: 20)
        let hyperJump = DoHyperspaceJumpComponent(size: .zero, randomness: Randomness.initialize(with: 1))
        let position = PositionComponent(x: 0, y: 0, z: .player)
        let display = DisplayComponent(sknode: SwashScaledSpriteNode())
        entity
                .add(component: hyperEngine)
                .add(component: hyperJump)
                .add(component: position)
                .add(component: display)
        for component in entity.components {
            node.components[type(of: component).name] = component
        }
        if system.nodeUpdateFunction == nil {
            XCTFail("nodeUpdateFunction is nil")
        } else {
            system.nodeUpdateFunction!(node, 1)
        }
        XCTAssertEqual(position.x, hyperJump.x)
        XCTAssertEqual(position.y, hyperJump.y)
        XCTAssertFalse(entity.has(componentClassName: DoHyperspaceJumpComponent.name))
        XCTAssertTrue(entity.has(componentClassName: AudioComponent.name))
    }
}
