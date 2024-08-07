//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

@testable import Swash
@testable import Swashteroids
import XCTest

final class ExitScreenSystemTests: XCTestCase {
    var system: TestableExitScreenSystem!
    var engine: Engine!
    var entity: Entity!
    var alienComponent: AlienComponent!

    override func setUpWithError() throws {
        system = TestableExitScreenSystem()
        engine = Engine()
        engine.add(system: system, priority: 1)
        //
        alienComponent = AlienComponent(cast: .worker)
        alienComponent.destinationStart = .zero
        alienComponent.destinationEnd = CGPoint(x: 100, y: 100)
        entity = Entity(named: "test")
                .add(component: ExitScreenComponent())
                .add(component: PositionComponent(x: 0, y: 0, z: .asteroids))
                .add(component: alienComponent)
        engine.add(entity: entity)
    }

    override func tearDownWithError() throws {
        system = nil
        engine = nil
        entity = nil
        alienComponent = nil
    }

    func test_updateNode_notReachedDestination() {
        engine.update(time: 1)
        XCTAssertNotNil(engine.findEntity(named: "test"))
        XCTAssertTrue(system.updateNodeCalled)
    }

    func test_updateNode_reachedDestination() {
        entity[PositionComponent.self]?.x = 100
        XCTAssertNotNil(engine.findEntity(named: "test"))
        engine.update(time: 1)
        XCTAssertNil(engine.findEntity(named: "test"))
        XCTAssertTrue(system.updateNodeCalled)
    }

    func test_updateNode_reachedNegativeDestination() {
        alienComponent.destinationEnd = CGPoint(x: -100, y: -100)
        entity[PositionComponent.self]?.x = -100
        XCTAssertNotNil(engine.findEntity(named: "test"))
        engine.update(time: 1)
        XCTAssertNil(engine.findEntity(named: "test"))
        XCTAssertTrue(system.updateNodeCalled)
    }

    final class TestableExitScreenSystem: ExitScreenSystem {
        var updateNodeCalled = false

        override func updateNode(node: Node, time: TimeInterval) {
            updateNodeCalled = true
            super.updateNode(node: node, time: time)
        }
    }
}

