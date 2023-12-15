//
// https://github.com/johnrnyquist/Swashteroids
//
// Swashteroids was made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import XCTest
@testable import Swashteroids
@testable import Swash

final class GameOverSystemTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_Init() throws {
        let system = GameOverSystem()
        XCTAssertTrue(system.nodeClass == GameOverNode.self)
        XCTAssertNotNil(system.nodeUpdateFunction)
    }

    func test_UpdateNode() throws {
        let gameOver = GameOverComponent()
        let appState = AppStateComponent(
            size: .zero,
            ships: 0,
            level: 1,
            score: 2,
            appState: .gameOver,
            shipControlsState: .showingButtons)
        let node = GameOverNode()
        node.components[GameOverComponent.name] = gameOver
        node.components[AppStateComponent.name] = appState
        let system = GameOverSystem()
        system.updateNode(node: node, time: 1)
        XCTAssertEqual(appState.appState, .gameOver)
        XCTAssertEqual(appState.level, 1)
        XCTAssertEqual(appState.score, 2)
    }
}
