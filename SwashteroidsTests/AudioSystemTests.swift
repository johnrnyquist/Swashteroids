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
import SpriteKit
@testable import Swashteroids
@testable import Swash

final class AudioSystemTests: XCTestCase {
    var system: AudioSystem!
    var node: AudioNode!
    var component: AudioComponent!

    override func setUpWithError() throws {
        component = AudioComponent(name: "bar", fileName: .thrust)
        node = AudioNode()
        node.components[AudioComponent.name] = component
        system = AudioSystem()
    }

    override func tearDownWithError() throws {
        system = nil
        node = nil
        component = nil
    }

    func test_Init() throws {
        XCTAssertTrue(system.nodeClass == AudioNode.self)
        XCTAssertNotNil(system.nodeUpdateFunction)
    }
}
