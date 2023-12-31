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
    var system: HyperspaceSystem!

    override func setUpWithError() throws {
        system = HyperspaceSystem()
    }
    
    override func tearDownWithError() throws {
        system = nil
    }

    func test_Init() throws {
        XCTAssertTrue(system.nodeClass == HyperspaceNode.self)
        XCTAssertNotNil(system.nodeUpdateFunction)
    }

    func test_UpdateNode() throws {
        let entity = Entity()
        let node = HyperspaceNode()
        node.entity = entity
        let hyperEngine = HyperspaceEngineComponent()
        let hyperJump = HyperspaceJumpComponent(size: .zero)
        let position = PositionComponent(x: 0, y: 0, z: .ship)
        let display = DisplayComponent(sknode: SwashSpriteNode())
        entity.add(component: hyperEngine)
        entity.add(component: hyperJump)
        entity.add(component: position)
        entity.add(component: display)
        node.components[HyperspaceEngineComponent.name] = hyperEngine
        node.components[HyperspaceJumpComponent.name] = hyperJump
        node.components[PositionComponent.name] = position
        node.components[DisplayComponent.name] = display
        if system.nodeUpdateFunction == nil {
            XCTFail("nodeUpdateFunction is nil")
        } else {
            system.nodeUpdateFunction!(node, 1)
        }
        XCTAssertEqual(position.x, hyperJump.x)
        XCTAssertEqual(position.y, hyperJump.y)
        XCTAssertFalse(entity.has(componentClassName: HyperspaceJumpComponent.name))
        XCTAssertTrue(entity.has(componentClassName: AudioComponent.name))
    }
}
