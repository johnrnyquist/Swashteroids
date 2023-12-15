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

final class RenderSystemTests: XCTestCase {
    var system: RenderSystem!
    var scene: SKScene! // we need this because RenderSystem holds a weak reference
    var engine: Engine!

    override func setUpWithError() throws {
        scene = SKScene()
        system = RenderSystem(container: scene)
        engine = Engine()
    }

    override func tearDownWithError() throws {
        scene = nil
        system = nil
        engine = nil
    }

    func test_Init() {
        XCTAssertNotNil(system.scene)
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
        let sprite = SwashSpriteNode()
        let display = DisplayComponent(sknode: sprite)
        let position = PositionComponent(x: 0, y: 0, z: .ship)
        entity
                .add(component: display)
                .add(component: position)
        try? engine.addEntity(entity: entity)
        engine.addSystem(system: system, priority: 1)
        XCTAssertTrue(scene.children.count == 1)
    }

    func test_RemoveFromDisplay() {
        engine.addSystem(system: system, priority: 1)
        let entity = Entity()
        let sprite = SwashSpriteNode()
        let display = DisplayComponent(sknode: sprite)
        let position = PositionComponent(x: 0, y: 0, z: .ship)
        entity
                .add(component: display)
                .add(component: position)
        try? engine.addEntity(entity: entity)
        engine.removeEntity(entity: entity)
        XCTAssertTrue(scene.children.count == 0)
    }
    
    func test_RemoveFromEngine() {
        engine.addSystem(system: system, priority: 1)
        engine.removeSystem(system: system)
        XCTAssertNil(system.nodes)
        XCTAssertNil(system.scene)
    }
}
