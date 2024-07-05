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
    var soundPlayer: MockSoundPlayer!

    override func setUpWithError() throws {
        component = AudioComponent(key: "bar", fileName: .thrust)
        node = AudioNode()
        node.components[AudioComponent.name] = component
        soundPlayer = MockSoundPlayer()
        system = AudioSystem(soundPlayer: soundPlayer)
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

    func test_UpdateNode() throws {
        system.updateNode(node: node, time: 1)
        XCTAssertTrue(soundPlayer.actionCalled)
        XCTAssertTrue(soundPlayer.runCalled)
    }

    class MockSoundPlayer: SoundPlaying {
        var actionCalled = false
        var runCalled = false

        func action(forKey key: String) -> SKAction? {
            actionCalled = true
            return nil
        }

        func run(_ action: SKAction, withKey: String) {
            runCalled = true
        }
    }
}
