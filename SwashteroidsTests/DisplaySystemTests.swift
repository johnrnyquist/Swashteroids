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
@testable import Swash
@testable import Swashteroids

final class DisplaySystemTests: XCTestCase {
    var system: DisplaySystem!
    var container: MockScene!
    var engine: Engine!

    override func setUpWithError() throws {
        container = MockScene()
        system = DisplaySystem(scene: container)
        engine = Engine()
    }

    override func tearDownWithError() throws {
        container = nil
        system = nil
        engine = nil
    }

    func test_Init() throws {
        XCTAssertNotNil(system.scene)
    }

    func test_Update() {
        let sprite = SwashScaledSpriteNode()
        let display = DisplayComponent(sknode: sprite)
        let position = PositionComponent(x: 1, y: 2, z: .player)
        let entity = Entity()
                .add(component: display)
                .add(component: position)
        engine.add(entity: entity)
        sprite.swashEntity = entity
        engine.add(system: system, priority: 1)
        system.update(time: 1)
        XCTAssertTrue(sprite.position.x == 1)
        XCTAssertTrue(sprite.position.y == 2)
    }

    func test_AddToSystem() {
        system.addToEngine(engine: engine)
        XCTAssertNotNil(system.nodes)
        if let nodes = system.nodes {
            XCTAssertTrue(nodes.nodeAdded.numListeners == 1)
            XCTAssertTrue(nodes.nodeRemoved.numListeners == 1)
            XCTAssertTrue(nodes.empty)
        } else {
            XCTFail("nodes is nil")
        }
    }

    func test_AddToDisplay() {
        let entity = Entity()
        let sprite = SwashScaledSpriteNode()
        let display = DisplayComponent(sknode: sprite)
        let position = PositionComponent(x: 0, y: 0, z: .player)
        entity
                .add(component: display)
                .add(component: position)
        engine.add(entity: entity)
        engine.add(system: system, priority: 1)
        XCTAssertTrue(container.children.count == 1)
    }

    func test_RemoveFromDisplay() {
        engine.add(system: system, priority: 1)
        let sprite = SwashScaledSpriteNode()
        let entity = Entity()
        entity
                .add(component: DisplayComponent(sknode: sprite))
                .add(component: PositionComponent(x: 0, y: 0, z: .player))
        engine.add(entity: entity)
        XCTAssertNotNil(sprite.parent)
        engine.remove(entity: entity)
        XCTAssertNil(sprite.parent)
    }

    func test_RemoveFromEngine() {
        engine.add(system: system, priority: 1)
        engine.remove(system: system)
        XCTAssertNil(system.nodes)
        XCTAssertNil(system.scene)
    }
}

import GameController

class MockScene: GameScene {
    override func didMove(to view: SKView) {}

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {}

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {}

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {}

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {}
}
