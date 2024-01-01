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
    var transition: Transition!
    var size: CGSize!
    var engine: Engine!

    override func setUpWithError() throws {
        size = CGSize(width: 1024.0, height: 768.0)
        engine = Engine()
        let creator = Creator(engine: engine, size: size, alertPresenter: MockAlertPresenter())
        transition = Transition(engine: engine, creator: creator)
        system = TransitionAppStateSystem(transition: transition)
    }

    override func tearDownWithError() throws {
        system = nil
        transition = nil
        size = nil
        engine = nil
    }

    func test_Init() throws {
        XCTAssertTrue(system.nodeClass == TransitionAppStateNode.self)
        XCTAssertNotNil(system.nodeUpdateFunction)
    }

    func test_UpdateNodeFromStartToInfoNoButtons() throws {
        let node = TransitionAppStateNode()
        let appStateComponent = AppStateComponent(size: size,
                                                  ships: 0,
                                                  level: 0,
                                                  score: 0,
                                                  appState: .start,
                                                  shipControlsState: .hidingButtons)
        let transitionComponent = TransitionAppStateComponent(to: .infoNoButtons, from: .start)
        node.components[AppStateComponent.name] = appStateComponent
        node.components[TransitionAppStateComponent.name] = transitionComponent
        system.updateNode(node: node, time: 1)
        XCTAssertEqual(appStateComponent.appState, .infoNoButtons)
    }

    func test_UpdateNodeFromStartToInfoButtons() throws {
        let node = TransitionAppStateNode()
        let appStateComponent = AppStateComponent(size: size,
                                                  ships: 0,
                                                  level: 0,
                                                  score: 0,
                                                  appState: .start,
                                                  shipControlsState: .showingButtons)
        let transitionComponent = TransitionAppStateComponent(to: .infoButtons, from: .start)
        node.components[AppStateComponent.name] = appStateComponent
        node.components[TransitionAppStateComponent.name] = transitionComponent
        system.updateNode(node: node, time: 1)
        XCTAssertEqual(appStateComponent.appState, .infoButtons)
    }

    func test_UpdateNodeFromInfoButtonsToPlaying() throws {
        let node = TransitionAppStateNode()
        let appStateComponent = AppStateComponent(size: size,
                                                  ships: 0,
                                                  level: 0,
                                                  score: 0,
                                                  appState: .infoButtons,
                                                  shipControlsState: .showingButtons)
        let transitionComponent = TransitionAppStateComponent(to: .playing, from: .infoButtons)
        node.components[AppStateComponent.name] = appStateComponent
        node.components[TransitionAppStateComponent.name] = transitionComponent
        system.updateNode(node: node, time: 1)
        XCTAssertEqual(appStateComponent.appState, .playing)
    }

    func test_UpdateNodeFromGameOverToStart() throws {
        let node = TransitionAppStateNode()
        let appStateComponent = AppStateComponent(size: size,
                                                  ships: 0,
                                                  level: 0,
                                                  score: 0,
                                                  appState: .gameOver,
                                                  shipControlsState: .showingButtons)
        let transitionComponent = TransitionAppStateComponent(to: .start,
                                                              from: .gameOver)
        node.components[AppStateComponent.name] = appStateComponent
        node.components[TransitionAppStateComponent.name] = transitionComponent
        system.updateNode(node: node, time: 1)
        XCTAssertEqual(appStateComponent.appState, .start)
    }

    func test_UpdateNodeFromInfoNoButtonsToPlaying() throws {
        let node = TransitionAppStateNode()
        let appStateComponent = AppStateComponent(size: size,
                                                  ships: 0,
                                                  level: 0,
                                                  score: 0,
                                                  appState: .infoNoButtons,
                                                  shipControlsState: .hidingButtons)
        let transitionComponent = TransitionAppStateComponent(to: .playing, from: .infoNoButtons)
        node.components[AppStateComponent.name] = appStateComponent
        node.components[TransitionAppStateComponent.name] = transitionComponent
        system.updateNode(node: node, time: 1)
        XCTAssertEqual(appStateComponent.appState, .playing)
    }

    func test_UpdateNodeFromPlayingWithButtonsToGameOver() throws {
        let appStateComponent = AppStateComponent(size: size,
                                                  ships: 0,
                                                  level: 0,
                                                  score: 0,
                                                  appState: .playing,
                                                  shipControlsState: .showingButtons)
        let appStateEntity = Entity(named: "appStateEntity")
                .add(component: appStateComponent)
        do {
            try engine.add(entity: appStateEntity)
        } catch {
            XCTFail("Failed to add appStateEntity")
        }
        let transitionComponent = TransitionAppStateComponent(to: .gameOver, from: .playing)
        let node = TransitionAppStateNode()
        node.components[AppStateComponent.name] = appStateComponent
        node.components[TransitionAppStateComponent.name] = transitionComponent
        system.updateNode(node: node, time: 1)
        XCTAssertEqual(appStateComponent.appState, .gameOver)
    }

    class MockAlertPresenter: AlertPresenting {
        func showPauseAlert() {}
    }
}
