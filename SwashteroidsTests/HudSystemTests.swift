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

class HudSystemTests: XCTestCase {
    var system: HudSystem!

    override func setUpWithError() throws {
        system = HudSystem()
    }

    override func tearDownWithError() throws {
        system = nil
    }

    func test_Init() throws {
        XCTAssertTrue(system.nodeClass == HudNode.self)
        XCTAssertNotNil(system.nodeUpdateFunction)
    }

    func test_UpdateNode() throws {
        let hudNode = HudNode()
        let hudComponent = HudComponent(hudView: HudView(gameSize: .zero))
        let appStateComponent = AppStateComponent(size: .zero,
                                                  ships: 1,
                                                  level: 2,
                                                  score: 3,
                                                  appState: .playing,
                                                  shipControlsState: .showingButtons)
        hudNode.components[HudComponent.name] = hudComponent
        hudNode.components[AppStateComponent.name] = appStateComponent
        system.updateNode(hudNode, 1)
        XCTAssertEqual(hudComponent.hudView.getNumShipsText(), "SHIPS: 1")
        XCTAssertEqual(hudComponent.hudView.getLevelText(), "LEVEL: 2")
        XCTAssertEqual(hudComponent.hudView.getScoreText(), "SCORE: 3")
    }
}