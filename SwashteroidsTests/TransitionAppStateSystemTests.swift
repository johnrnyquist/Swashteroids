//
//  TransitionSystemTests.swift
//  SwashteroidsTests
//
//  Created by John Nyquist on 12/15/23.
//

import XCTest
import SpriteKit
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
        let creator = Creator(engine: engine, size: size)
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

    func test_UpdateNodeFromInitialize() throws {
        let node = TransitionAppStateNode()
        let appStateComponent = AppStateComponent(size: size, appState: .initialize)
        let transitionComponent = TransitionAppStateComponent(to: .start, from: .initialize)
        node.components[AppStateComponent.name] = appStateComponent
        node.components[TransitionAppStateComponent.name] = transitionComponent
        system.updateNode(node: node, time: 1)
        XCTAssertEqual(appStateComponent.appState, .start)
    }

    func test_UpdateNodeFromStartToInfoNoButtons() throws {
        let node = TransitionAppStateNode()
        let appStateComponent = AppStateComponent(size: size, appState: .start, shipControlsState: .hidingButtons)
        let transitionComponent = TransitionAppStateComponent(to: .infoNoButtons, from: .start)
        node.components[AppStateComponent.name] = appStateComponent
        node.components[TransitionAppStateComponent.name] = transitionComponent
        system.updateNode(node: node, time: 1)
        XCTAssertEqual(appStateComponent.appState, .infoNoButtons)
    }

    func test_UpdateNodeFromStartToInfoButtons() throws {
        let node = TransitionAppStateNode()
        let appStateComponent = AppStateComponent(size: size, appState: .start, shipControlsState: .showingButtons)
        let transitionComponent = TransitionAppStateComponent(to: .infoButtons, from: .start)
        node.components[AppStateComponent.name] = appStateComponent
        node.components[TransitionAppStateComponent.name] = transitionComponent
        system.updateNode(node: node, time: 1)
        XCTAssertEqual(appStateComponent.appState, .infoButtons)
    }

    func test_UpdateNodeFromInfoButtonsToPlaying() throws {
        let node = TransitionAppStateNode()
        let appStateComponent = AppStateComponent(size: size, appState: .infoButtons, shipControlsState: .showingButtons)
        let transitionComponent = TransitionAppStateComponent(to: .playing, from: .infoButtons)
        node.components[AppStateComponent.name] = appStateComponent
        node.components[TransitionAppStateComponent.name] = transitionComponent
        system.updateNode(node: node, time: 1)
        XCTAssertEqual(appStateComponent.appState, .playing)
    }

    func test_UpdateNodeFromGameOverToStart() throws {
        let node = TransitionAppStateNode()
        let appStateComponent = AppStateComponent(size: size, appState: .gameOver, shipControlsState: .showingButtons)
        let transitionComponent = TransitionAppStateComponent(to: .start, from: .gameOver)
        node.components[AppStateComponent.name] = appStateComponent
        node.components[TransitionAppStateComponent.name] = transitionComponent
        system.updateNode(node: node, time: 1)
        XCTAssertEqual(appStateComponent.appState, .start)
    }

    func test_UpdateNodeFromInfoNoButtonsToPlaying() throws {
        let node = TransitionAppStateNode()
        let appStateComponent = AppStateComponent(size: size, appState: .infoNoButtons, shipControlsState: .hidingButtons)
        let transitionComponent = TransitionAppStateComponent(to: .playing, from: .infoNoButtons)
        node.components[AppStateComponent.name] = appStateComponent
        node.components[TransitionAppStateComponent.name] = transitionComponent
        system.updateNode(node: node, time: 1)
        XCTAssertEqual(appStateComponent.appState, .playing)
    }

    func test_UpdateNodeFromPlayingWithButtonsToGameOver() throws {
        let appStateComponent = AppStateComponent(size: size, appState: .playing)
        let appStateEntity = Entity(name: "appStateEntity")
                .add(component: appStateComponent)
        do {
            try engine.addEntity(entity: appStateEntity)
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
}
