//
// https://github.com/johnrnyquist/Swashteroids
//
// Swashteroids was made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import XCTest
@testable import Swashteroids
import Swash
import SpriteKit

final class BulletAgeSystemTests: XCTestCase {
    var component: PlasmaTorpedoComponent!
    var node: BulletAgeNode!
    var system: BulletAgeSystem!
    var creator: MockCreator!
    var entity = Entity(name: "bullet")

    override func setUpWithError() throws {
        component = PlasmaTorpedoComponent(lifeRemaining: 1)
        entity.add(component: component)
        creator = MockCreator(engine: Engine(), inputComponent: InputComponent(), scene: MockScene(), size: CGSize(width: 1024, height: 768))
        node = BulletAgeNode() // nodes created by engine
        node.entity = entity   // done by engine
        node.components[PlasmaTorpedoComponent.name] = component
        system = BulletAgeSystem(creator: creator)
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
        XCTAssertTrue(creator.destroyEntityCalled)
    }

    func testLifeLessThanZeroNoEntity() throws {
        system.updateNode(node: node, time: 1.25)
        XCTAssertEqual(component.lifeRemaining, -0.25)
        XCTAssertFalse(creator.destroyEntityCalled)
    }
}

class MockCreator: Creator {
    var destroyEntityCalled = false

    override func destroyEntity(_ entity: Entity) {
        destroyEntityCalled = true
    }
}

class MockScene: SKScene {
}
