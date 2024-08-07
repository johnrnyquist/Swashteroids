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
@testable import Swashteroids
@testable import Swash

final class AlienAppearancesSystemTests: XCTestCase {
    var system: TestableAlienAppearancesSystem!
    var engine: Engine!
    var mockAlienCreator: MockAlienCreator!
    var gameStateComponent: GameStateComponent!
    var appState: Entity!

    override func setUpWithError() throws {
        mockAlienCreator = MockAlienCreator()
        system = TestableAlienAppearancesSystem(alienCreator: mockAlienCreator)
        engine = Engine()
        engine.add(system: system, priority: 1)
        //
        appState = Entity(named: .appState)
        gameStateComponent = GameStateComponent(config: GameConfig(gameSize: .zero))
        gameStateComponent.gameScreen = .playing
        appState
                .add(component: gameStateComponent)
                .add(component: AlienAppearancesComponent.shared)
        engine.add(entity: appState)
    }

    override func tearDownWithError() throws {
        system = nil
        engine = nil
        mockAlienCreator = nil
        gameStateComponent = nil
        appState = nil
    }

    // NOTE: This test illustrates how ListIteratingSystems are only called when a node of the right type exists. 
    // This is NOT the same as the guard failing.
    func test_updateNode_notCalled() {
        appState.remove(componentClass: AlienAppearancesComponent.self)
        engine.update(time: 1)
        XCTAssertFalse(system.updateNodeCalled)
        XCTAssertFalse(mockAlienCreator.createAliensCalled)
    }

    func test_updateNode_alienCreated() throws {
        gameStateComponent.alienNextAppearance = 0
        engine.update(time: 1)
        XCTAssertTrue(system.updateNodeCalled)
        XCTAssertTrue(mockAlienCreator.createAliensCalled)
    }

    func test_updateNode_alienNotCreated() {
        engine.update(time: 1)
        XCTAssertTrue(system.updateNodeCalled)
        XCTAssertFalse(mockAlienCreator.createAliensCalled)
    }

    final class TestableAlienAppearancesSystem: AlienAppearancesSystem {
        var updateNodeCalled = false

        override func updateNode(node: Node, time: TimeInterval) {
            updateNodeCalled = true
            super.updateNode(node: node, time: time)
        }
    }
}

