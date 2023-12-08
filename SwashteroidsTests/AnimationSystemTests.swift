//
// https://github.com/johnrnyquist/Swashteroids
//
// Swashteroids was made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import XCTest
@testable import Swashteroids

final class AnimationSystemTests: XCTestCase {
    var thing: Thing!
    var component: AnimationComponent!
    var node: AnimationNode!
    var system: AnimationSystem!

    override func setUpWithError() throws {
        thing = Thing()
        component = AnimationComponent(animation: thing)
        node = AnimationNode() // nodes created by engine
        node.components[AnimationComponent.name] = component
        system = AnimationSystem()
    }

    override func tearDownWithError() throws {
    }

    func testUpdateNode() throws {
        system.updateNode(node: node, time: 1)
        XCTAssertEqual(thing.counter, 1)
    }
}

class Thing: Animatable {
    var counter = 0

    func animate(_ time: TimeInterval) {
        counter += 1
    }
}
