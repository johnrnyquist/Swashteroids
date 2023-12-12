//
// https://github.com/johnrnyquist/Swashteroids
//
// Swashteroids was made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import XCTest
import SpriteKit
@testable import Swash
@testable import Swashteroids

final class BulletAgeSystemTests: XCTestCase {
    var component: PlasmaTorpedoComponent!
    var node: BulletAgeNode!
    var entity: Entity!
    var system: BulletAgeSystem!
    var engine: MockEngine!

    override func setUpWithError() throws {
        entity = Entity()
        engine = MockEngine()
        component = PlasmaTorpedoComponent(lifeRemaining: 1)
        node = BulletAgeNode()
        node.entity = entity
        node.components[PlasmaTorpedoComponent.name] = component
        system = BulletAgeSystem()
        system.addToEngine(engine: engine)
    }

    func testNodeDoesNotContainBullet() throws {
        node.components = [:]
        system.updateNode(node: node, time: 1)
        XCTAssertEqual(component.lifeRemaining, 1)
    }

    func testLifeIsDecrementedByTime() throws {
        system.updateNode(node: node, time: 0.25)
        XCTAssertEqual(component.lifeRemaining, 0.75)
    }

    func testLifeLessThanZeroDestroysEntity() throws {
        system.updateNode(node: node, time: 1.25)
        XCTAssertEqual(component.lifeRemaining, -0.25)
        XCTAssertTrue(engine.destroyEntityCalled)
    }

    func testLifeLessThanZeroNoEntity() throws {
        node.entity = nil
        system.updateNode(node: node, time: 1.25)
        XCTAssertEqual(component.lifeRemaining, -0.25)
        XCTAssertFalse(engine.destroyEntityCalled)
    }
}

class MockEngine: Engine {
    var destroyEntityCalled = false

    override func removeEntity(entity: Entity) {
        destroyEntityCalled = true
    }
}

class MockScene: SKScene {
}
