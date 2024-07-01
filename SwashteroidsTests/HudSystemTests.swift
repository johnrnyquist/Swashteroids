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
    var powerUpCreator: PowerUpCreatorUseCase!
    var engine: Engine!

    override func setUpWithError() throws {
        powerUpCreator = MockPowerUpCreator()
        system = HudSystem(powerUpCreator: powerUpCreator)
        engine = Engine()
        engine.add(system: system, priority: 1)
        let entity = Entity(named: .appState)
        entity.add(component: GameStateComponent(config: GameConfig(gameSize: .zero)))
        engine.add(entity: entity)
    }

    override func tearDownWithError() throws {
        system = nil
    }
    
    func test_UpdateNode() throws {
        let hudNode = HudNode()
        let hudComponent = HudComponent(hudView: HudView(gameSize: .zero))
        let appStateComponent = engine.gameStateComponent
        appStateComponent.numShips = 1
        appStateComponent.level = 2
        appStateComponent.score = 3
        hudNode.components[HudComponent.name] = hudComponent
//        hudNode.components[SwashteroidsStateComponent.name] = appStateComponent
        system.updateNode(hudNode, 1)
        XCTAssertEqual(hudComponent.hudView.getNumShipsText(), "SHIPS: 1")
        XCTAssertEqual(hudComponent.hudView.getLevelText(), "LEVEL: 2")
        XCTAssertEqual(hudComponent.hudView.getScoreText(), "SCORE: 3")
    }

}

