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

final class TorpedoAgeSystemTests: XCTestCase {
    var component: PlasmaTorpedoComponent!
    var node: TorpedoAgeNode!
    var entity: Entity!
    var system: TorpedoAgeSystem!
    var engine: MockEngine!

    override func setUpWithError() throws {
        entity = Entity()
        engine = MockEngine()
        component = PlasmaTorpedoComponent(lifeRemaining: 1)
        node = TorpedoAgeNode()
        node.entity = entity
        node.components[PlasmaTorpedoComponent.name] = component
        system = TorpedoAgeSystem()
        system.addToEngine(engine: engine)
    }

    override func tearDownWithError() throws { 
        component = nil
        node = nil
        entity = nil
        system = nil
        engine = nil
    }

    func test_Init() throws {
        XCTAssertTrue(system.nodeClass == TorpedoAgeNode.self)
        XCTAssertNotNil(system.nodeUpdateFunction)
    }

    func test_NodeDoesNotContainBullet() throws {
        node.components = [:]
        system.updateNode(node: node, time: 1)
        XCTAssertEqual(component.lifeRemaining, 1)
    }

    func test_LifeIsDecrementedByTime() throws {
        system.updateNode(node: node, time: 0.25)
        XCTAssertEqual(component.lifeRemaining, 0.75)
    }

    func test_LifeLessThanZeroDestroysEntity() throws {
        system.updateNode(node: node, time: 1.25)
        XCTAssertEqual(component.lifeRemaining, -0.25)
        XCTAssertTrue(engine.destroyEntityCalled)
    }

    func test_LifeLessThanZeroNoEntity() throws {
        node.entity = nil
        system.updateNode(node: node, time: 1.25)
        XCTAssertEqual(component.lifeRemaining, -0.25)
        XCTAssertFalse(engine.destroyEntityCalled)
    }

    class MockEngine: Engine {
        var destroyEntityCalled = false

        override func remove(entity: Entity) {
            destroyEntityCalled = true
        }
    }
}

