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
        system = TransitionAppStateSystem(startTransition: StartTransition(engine: engine, generator: nil),
                                          infoViewsTransition: InfoViewsTransition(engine: engine, generator: nil), 
                                          playingTransition: PlayingTransition(hudCreator: MockHudCreator(), 
                                                                               toggleShipControlsCreator: creator,
                                                                               shipControlQuadrantsCreator: creator,
                                                                               shipButtonControlsCreator: creator),
                                          gameOverTransition: GameOverTransition(engine: engine, generator: nil))
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

    func test_UpdateNodeFromStartToInfoNoButtons() throws {
        let node = TransitionAppStateNode()
        let appStateComponent = AppStateComponent(gameSize: size,
                                                  numShips: 0,
                                                  level: 0,
                                                  score: 0,
                                                  appState: .start,
                                                  shipControlsState: .hidingButtons,
                                                  randomness: Randomness.initialize(with: 1))
        let transitionComponent = TransitionAppStateComponent(from: .start, to: .infoNoButtons)
        node.components[AppStateComponent.name] = appStateComponent
        node.components[TransitionAppStateComponent.name] = transitionComponent
        let appState = Entity(named: .appState)
            .add(component: AppStateComponent(gameSize: .zero, numShips: 0, level: 0, score: 0, appState: .start, shipControlsState: .hidingButtons, randomness: Randomness.initialize(with: 1)))
        engine.replace(entity: appState)
        // SUT
        system.updateNode(node: node, time: 1)
        //
        XCTAssertEqual(appStateComponent.appState, .infoNoButtons)
    }

    func test_UpdateNodeFromStartToInfoButtons() throws {
        let node = TransitionAppStateNode()
        let appStateComponent = AppStateComponent(gameSize: size,
                                                  numShips: 0,
                                                  level: 0,
                                                  score: 0,
                                                  appState: .start,
                                                  shipControlsState: .showingButtons,
                                                  randomness: Randomness.initialize(with: 1))
        let transitionComponent = TransitionAppStateComponent(from: .start, to: .infoButtons)
        node.components[AppStateComponent.name] = appStateComponent
        node.components[TransitionAppStateComponent.name] = transitionComponent
        let appState = Entity(named: .appState)
            .add(component: AppStateComponent(gameSize: .zero, numShips: 0, level: 0, score: 0, appState: .start, shipControlsState: .hidingButtons, randomness: Randomness.initialize(with: 1)))
        engine.replace(entity: appState)
        // SUT
        system.updateNode(node: node, time: 1)
        //
        XCTAssertEqual(appStateComponent.appState, .infoButtons)
    }

    func test_UpdateNodeFromInfoButtonsToPlaying() throws {
        let node = TransitionAppStateNode()
        let appStateComponent = AppStateComponent(gameSize: size,
                                                  numShips: 0,
                                                  level: 0,
                                                  score: 0,
                                                  appState: .infoButtons,
                                                  shipControlsState: .showingButtons,
                                                  randomness: Randomness.initialize(with: 1))
        let transitionComponent = TransitionAppStateComponent(from: .infoButtons, to: .playing)
        node.components[AppStateComponent.name] = appStateComponent
        node.components[TransitionAppStateComponent.name] = transitionComponent
        // SUT
        system.updateNode(node: node, time: 1)
        //
        XCTAssertEqual(appStateComponent.appState, .playing)
    }

    func test_UpdateNodeFromGameOverToStart() throws {
        let node = TransitionAppStateNode()
        let appStateComponent = AppStateComponent(gameSize: size,
                                                  numShips: 0,
                                                  level: 0,
                                                  score: 0,
                                                  appState: .gameOver,
                                                  shipControlsState: .showingButtons,
                                                  randomness: Randomness.initialize(with: 1))
        let transitionComponent = TransitionAppStateComponent(from: .gameOver, to: .start)
        node.components[AppStateComponent.name] = appStateComponent
        node.components[TransitionAppStateComponent.name] = transitionComponent
        let appState = Entity(named: .appState)
            .add(component: AppStateComponent(gameSize: .zero, numShips: 0, level: 0, score: 0, appState: .start, shipControlsState: .hidingButtons, randomness: Randomness.initialize(with: 1)))
        engine.replace(entity: appState)
        // SUT
        system.updateNode(node: node, time: 1)
        //
        XCTAssertEqual(appStateComponent.appState, .start)
    }

    func test_UpdateNodeFromInfoNoButtonsToPlaying() throws {
        let node = TransitionAppStateNode()
        let appStateComponent = AppStateComponent(gameSize: size,
                                                  numShips: 0,
                                                  level: 0,
                                                  score: 0,
                                                  appState: .infoNoButtons,
                                                  shipControlsState: .hidingButtons,
                                                  randomness: Randomness.initialize(with: 1))
        let transitionComponent = TransitionAppStateComponent(from: .infoNoButtons, to: .playing)
        node.components[AppStateComponent.name] = appStateComponent
        node.components[TransitionAppStateComponent.name] = transitionComponent
        // SUT
        system.updateNode(node: node, time: 1)
        //
        XCTAssertEqual(appStateComponent.appState, .playing)
    }

    func test_UpdateNodeFromPlayingWithButtonsToGameOver() throws {
        let appStateComponent = AppStateComponent(gameSize: size,
                                                  numShips: 0,
                                                  level: 0,
                                                  score: 0,
                                                  appState: .playing,
                                                  shipControlsState: .showingButtons,
                                                  randomness: Randomness.initialize(with: 1))
        let appStateEntity = Entity(named: "appStateEntity")
                .add(component: appStateComponent)
        do {
            try engine.add(entity: appStateEntity)
        } catch {
            XCTFail("Failed to add appStateEntity")
        }
        let transitionComponent = TransitionAppStateComponent(from: .playing, to: .gameOver)
        let node = TransitionAppStateNode()
        node.components[AppStateComponent.name] = appStateComponent
        node.components[TransitionAppStateComponent.name] = transitionComponent
        // SUT
        system.updateNode(node: node, time: 1)
        //
        XCTAssertEqual(appStateComponent.appState, .gameOver)
    }
}
