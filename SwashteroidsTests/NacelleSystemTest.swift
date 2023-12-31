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

class NacellesSystemTests: XCTestCase {
    var system: NacellesSystem!

    override func setUpWithError() throws {
        system = NacellesSystem()
    }

    override func tearDownWithError() throws {
        system = nil
    }

    func test_Init() throws {
        XCTAssertTrue(system.nodeClass == ShipEngineNode.self)
        XCTAssertNotNil(system.nodeUpdateFunction)
    }

    func test_Warping() throws {
        let warpdrive = WarpDriveComponent()
        warpdrive.isThrusting = true
        let sprite = SwashSpriteNode()
        let nacelles = SwashSpriteNode()
        nacelles.name = "nacelles"
        sprite.addChild(nacelles)   
        let display = DisplayComponent(sknode: sprite)
        let node = ShipEngineNode()
        node.components[WarpDriveComponent.name] = warpdrive
        node.components[DisplayComponent.name] = display
        if system.nodeUpdateFunction == nil {
            XCTFail("nodeUpdateFunction is nil")
        } else {
            system.nodeUpdateFunction!(node, 1)
        }
        XCTAssertFalse(sprite.childNode(withName: "//nacelles")!.isHidden)
    }
    
    func test_NotWarping() throws {
        let warpdrive = WarpDriveComponent()
        warpdrive.isThrusting = false
        let sprite = SwashSpriteNode()
        let nacelles = SwashSpriteNode()
        nacelles.name = "nacelles"
        sprite.addChild(nacelles)   
        let display = DisplayComponent(sknode: sprite)
        let node = ShipEngineNode()
        node.components[WarpDriveComponent.name] = warpdrive
        node.components[DisplayComponent.name] = display
        if system.nodeUpdateFunction == nil {
            XCTFail("nodeUpdateFunction is nil")
        } else {
            system.nodeUpdateFunction!(node, 1)
        }
        XCTAssertTrue(sprite.childNode(withName: "//nacelles")!.isHidden)
    }
}
