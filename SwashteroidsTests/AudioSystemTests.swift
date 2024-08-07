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
    var engine: Engine!
    var system: TestableAudioSystem!
    var component: AudioComponent!
    var entity: Entity!

    override func setUpWithError() throws {
        system = TestableAudioSystem()
        component = AudioComponent(asset: .thrust)
        entity = Entity()
        entity.add(component: component)
        engine = Engine()
        engine.add(system: system, priority: 0)
        engine.add(entity: entity)
    }

    override func tearDownWithError() throws {
        system = nil
        component = nil
        engine = nil
    }

    func test_init() throws {
        XCTAssertTrue(system.nodeClass == AudioNode.self)
        XCTAssertNotNil(system.nodeUpdateFunction)
    }

    func test_updateNode_playSound() throws {
        engine.update(time: 1)
        XCTAssertTrue(system.updateNodeCalled)
        XCTAssertNil(entity[AudioComponent.self])
    }

    func test_updateNode_noPlaySound() throws {
        entity.remove(componentClass: AudioComponent.self)
        engine.update(time: 1)
        XCTAssertFalse(system.updateNodeCalled)
        XCTAssertNil(entity[AudioComponent.self])
    }
    
    final class TestableAudioSystem: AudioSystem {
        var updateNodeCalled = false
        override func updateNode(node: Node, time: TimeInterval) {
            updateNodeCalled = true
            super.updateNode(node: node, time: time)
        }
    }
}
