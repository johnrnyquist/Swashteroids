//
// https://github.com/johnrnyquist/Swashteroids
//
// Swashteroids was made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import XCTest
@testable import Swashteroids
@testable import Swash

final class AnimationTests: XCTestCase {
    var system: AnimationSystem!
    var node: AnimationNode!
    var component: AnimationComponent!
    var thing: Thing!

    override func setUpWithError() throws {
        thing = Thing()
        // The AnimationComponent takes something that conforms to the Animate protocol
        component = AnimationComponent(animation: thing)
        // Nodes are normally created by the engine
        node = AnimationNode()
        node.components[AnimationComponent.name] = component
        system = AnimationSystem()
    }

    override func tearDownWithError() throws { 
        system = nil
        node = nil
        component = nil
        thing = nil
    }

    func test_Init() throws {
        system = AnimationSystem()
        XCTAssertTrue(system.nodeClass == AnimationNode.self)
        XCTAssertNotNil(system.nodeUpdateFunction)
    }

    func test_UpdateNode() throws {
        system.updateNode(node: node, time: 1) // normally called by engine
        XCTAssertEqual(thing.counter, 1)
    }
}

class Thing: Animate {
    var counter = 0

    func animate(_ time: TimeInterval) {
        counter += 1
    }
}
