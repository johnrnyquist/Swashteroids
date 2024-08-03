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

final class TransitionAppStateSystemTests: XCTestCase {
    var system: TransitionAppStateSystem!
    var size: CGSize!
    var engine: Engine!

    override func setUpWithError() throws {
        size = CGSize(width: 1024.0, height: 768.0)
        engine = Engine()
        let creator = MockQuadrantsButtonToggleCreator()
        system = TransitionAppStateSystem(startTransition: StartTransition(engine: engine,
                                                                           startScreenCreator: MockStartScreenCreator()),
                                          playingTransition: PlayingTransition(hudCreator: MockHudCreator(),
                                                                               toggleShipControlsCreator: creator,
                                                                               shipControlQuadrantsCreator: creator,
                                                                               shipButtonControlsCreator: creator),
                                          gameOverTransition: GameOverTransition(engine: engine, alert: MockAlertPresenter()),
                                          tutorialTransition: TutorialTransition(engine: engine))
    }

    override func tearDownWithError() throws {
        system = nil
        engine = nil
        size = nil
    }

    func test_Init() throws {
        XCTAssertTrue(system.nodeClass == TransitionAppStateNode.self)
        XCTAssertNotNil(system.nodeUpdateFunction)
    }

    func test_UpdateNodeFromGameOverToStart() throws {
        let node = TransitionAppStateNode()
        let appStateComponent = GameStateComponent(config: GameConfig(gameSize: .zero))
        appStateComponent.numShips = 0
        appStateComponent.level = 0
        appStateComponent.score = 0
        appStateComponent.gameScreen = .gameOver
        let transitionComponent = ChangeGameStateComponent(from: .gameOver, to: .start)
        node.components[GameStateComponent.name] = appStateComponent
        node.components[ChangeGameStateComponent.name] = transitionComponent
        let appState = Entity(named: .appState)
                .add(component: appStateComponent)
        engine.add(entity: appState)
        // SUT
        system.updateNode(node: node, time: 1)
        //
        XCTAssertEqual(appStateComponent.gameScreen, .start)
    }

    func test_UpdateNodeFromPlayingWithButtonsToGameOver() throws {
        let appStateComponent = GameStateComponent(config: GameConfig(gameSize: .zero))
        appStateComponent.numShips = 0
        appStateComponent.level = 0
        appStateComponent.score = 0
        appStateComponent.gameScreen = .playing
        let appStateEntity = Entity(named: "appStateEntity")
                .add(component: appStateComponent)
        engine.add(entity: appStateEntity)
        let transitionComponent = ChangeGameStateComponent(from: .playing, to: .gameOver)
        let node = TransitionAppStateNode()
        node.components[GameStateComponent.name] = appStateComponent
        node.components[ChangeGameStateComponent.name] = transitionComponent
        // SUT
        system.updateNode(node: node, time: 1)
        //
        XCTAssertEqual(appStateComponent.gameScreen, .gameOver)
    }
}
