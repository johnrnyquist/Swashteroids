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

// TODO:
// I knew the code being tested was an issue, the testing of it confirms it.
// I need to rethink transitions. This may be an argument for GameplayKit transitions.
final class TransitionTests: XCTestCase {
    var transition: Transition!
    var size: CGSize!
    var engine: Engine!
    var creator: MockCreator!
    var appStateComponent: AppStateComponent!
    var appStateEntity: Entity!

    override func setUpWithError() throws {
        size = CGSize(width: 1024.0, height: 768.0)
        engine = Engine()
        appStateComponent = AppStateComponent(gameSize: .zero, numShips: 3, level: 4, score: 5, appState: .infoButtons, shipControlsState: .hidingButtons, randomness: Randomness(seed: 1))
        appStateEntity = Entity(named: "appStateEntity")
                .add(component: appStateComponent)
        do {
            try engine.add(entity: appStateEntity)
        } catch {
            XCTFail("Failed to add appStateEntity")
        }
        creator = MockCreator()
        transition = Transition(engine: engine, creator: creator)
    }

    override func tearDownWithError() throws {
        size = nil
        engine = nil
        appStateComponent = nil
        appStateEntity = nil
        creator = nil
        transition = nil
    }

    //TODO: This test is a little light.
    func test_ToStartScreen() {
        transition.toStartScreen()
        for entityName: EntityName in [.start, .noButtons, .withButtons] {
            XCTAssertNotNil(engine.findEntity(named: entityName))
        }
    }

    func test_FromStartScreen() {
        transition.fromStartScreen()
        for entityName: EntityName in [.start, .noButtons, .withButtons] {
            XCTAssertNil(engine.findEntity(named: entityName))
        }
    }
    
    func test_FromPlayingScreen() {
        transition.fromPlayingScreen()
        XCTAssertTrue(creator.removeToggleButtonCalled)
        XCTAssertTrue(creator.removeShipControlButtonsCalled)
        XCTAssertTrue(creator.removeShipControlQuadrantsCalled)
    }

    func test_FromGameOverScreen() {
        transition.fromGameOverScreen()
        let asteroids = engine.getNodeList(nodeClassType: AsteroidCollisionNode.self)
        XCTAssertNil(asteroids.head)
        for entityName: EntityName in [.hud, .gameOver, .hyperspacePowerUp, .torpedoPowerUp] {
            XCTAssertNil(engine.findEntity(named: entityName))
        }
        XCTAssertEqual(appStateComponent.score, appStateComponent.orig_score)
        XCTAssertEqual(appStateComponent.level, appStateComponent.orig_level)
        XCTAssertEqual(appStateComponent.numShips, appStateComponent.orig_numShips)
    }

    func test_ToGameOverScreen() {
        transition.toGameOverScreen()
        guard let gameOverEntity = engine.findEntity(named: .gameOver) else {
            XCTFail("gameOverEntity was nil")
            return
        }
        XCTAssertTrue(gameOverEntity.has(componentClassName: GameOverComponent.name))
        XCTAssertTrue(gameOverEntity.has(componentClassName: DisplayComponent.name))
        XCTAssertTrue(gameOverEntity.has(componentClassName: PositionComponent.name))
        XCTAssertTrue(gameOverEntity.has(componentClassName: TouchableComponent.name))
        XCTAssertTrue(gameOverEntity.has(componentClassName: AppStateComponent.name))
        XCTAssertTrue(gameOverEntity.has(componentClassName: ButtonBehaviorComponent.name))
        guard let display = gameOverEntity[DisplayComponent.self]
        else {
            XCTFail("display was nil")
            return
        }
        XCTAssertNotNil(display.sknode)
    }

    class MockAlertPresenter: AlertPresenting {
        var isAlertPresented: Bool = false

        func home() {}
        
        func resume() {}
        
        func showPauseAlert() {}
    }

    class MockCreator: HudCreatorUseCase, ToggleShipControlsManagerUseCase, ShipQuadrantsControlsManagerUseCase, ShipButtonControlsManagerUseCase {
        //MARK: - HudCreator
        var createHudCalled = false

        func createHud(gameState: AppStateComponent) {
            createHudCalled = true
        }

        //MARK: - ToggleShipControlsManager
        var createToggleButtonCalled = false
        var removeToggleButtonCalled = false

        func createToggleButton(_ state: Toggle) {
            createToggleButtonCalled = true
        }

        func removeToggleButton() {
            removeToggleButtonCalled = true
        }

        //MARK: - ShipQuadrantsControlsManager
        var createShipControlQuadrantsCalled = false
        var removeShipControlQuadrantsCalled = false

        func createShipControlQuadrants() {
            createShipControlQuadrantsCalled = true
        }

        func removeShipControlQuadrants() {
            removeShipControlQuadrantsCalled = true
        }

        //MARK: - ShipButtonControlsManager
        var createShipControlButtonsCalled = false
        var enableShipControlButtonsCalled = false
        var removeShipControlButtonsCalled = false
        var showFireButtonCalled = false
        var showHyperspaceButtonCalled = false

        func showFireButton() {
            showFireButtonCalled = true
        }

        func showHyperspaceButton() {
            showHyperspaceButtonCalled = true
        }

        func enableShipControlButtons() {
            enableShipControlButtonsCalled = true
        }

        func removeShipControlButtons() {
            removeShipControlButtonsCalled = true
        }

        func createShipControlButtons() {
            createShipControlButtonsCalled = true
        }
    }
}
