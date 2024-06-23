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

final class GameOverSystemTests: XCTestCase {
    var system: GameOverSystem!

    override func setUpWithError() throws {
        system = GameOverSystem()
    }

    override func tearDownWithError() throws {
        system = nil
    }

    func test_Init() throws {
        XCTAssertTrue(system.nodeClass == GameOverNode.self)
        XCTAssertNotNil(system.nodeUpdateFunction)
    }

    func test_UpdateNode() throws {
        let gameOver = GameOverComponent()
        let appStateComponent = AppStateComponent(gameConfig: GameConfig(gameSize: .zero),
                                                  randomness: Randomness.initialize(with: 1))
        appStateComponent.appState = .gameOver
        let node = GameOverNode()
        node.components[GameOverComponent.name] = gameOver
        node.components[AppStateComponent.name] = appStateComponent
        system = GameOverSystem()
        system.updateNode(node: node, time: 1)
        XCTAssertEqual(appStateComponent.appState, .gameOver)
    }
}
