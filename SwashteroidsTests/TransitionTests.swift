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
    var startTransition: StartUseCase!
    var playingTransition: PlayingUseCase!
    var gameOverTransition: GameOverUseCase!
    var size: CGSize!
    var engine: Engine!
    var creator: MockQuadrantsButtonToggleCreator!
    var appStateComponent: GameStateComponent!
    var appStateEntity: Entity!

    override func setUpWithError() throws {
        size = CGSize(width: 1024.0, height: 768.0)
        engine = Engine()
        appStateComponent = GameStateComponent(config: GameConfig(gameSize: .zero))
        appStateComponent.level = 4
        appStateComponent.score = 5
        appStateComponent.numShips = 3
        appStateComponent.shipControlsState = .usingAccelerometer
        appStateEntity = Entity(named: "appStateEntity")
                .add(component: appStateComponent)
        engine.add(entity: appStateEntity)
        creator = MockQuadrantsButtonToggleCreator()
        // Transitions
        startTransition = StartTransition(engine: engine, startScreenCreator: StartScreenCreator(engine: engine, gameSize: size))
        gameOverTransition = GameOverTransition(engine: engine, alert: MockAlertPresenter())
        playingTransition = PlayingTransition(hudCreator: MockHudCreator(),
                                              toggleShipControlsCreator: creator,
                                              shipControlQuadrantsCreator: creator,
                                              shipButtonControlsCreator: creator)
    }

    override func tearDownWithError() throws {
        size = nil
        engine = nil
        appStateComponent = nil
        appStateEntity = nil
        creator = nil
    }

    //TODO: This test is a little light.
    func test_ToStartScreen() {
        startTransition.toStartScreen()
        for entityName: EntityName in [.appState, .start, .withButtons, .tutorialButton] {
            XCTAssertNotNil(engine.findEntity(named: entityName))
        }
    }

    func test_FromStartScreen() {
        startTransition.fromStartScreen()
        for entityName: EntityName in [.start, .noButtons, .withButtons] {
            XCTAssertNil(engine.findEntity(named: entityName))
        }
    }

    func test_FromPlayingScreen() {
        playingTransition.fromPlayingScreen()
        XCTAssertTrue(creator.removeToggleButtonCalled)
        XCTAssertTrue(creator.removeShipControlButtonsCalled)
        XCTAssertTrue(creator.removeShipControlQuadrantsCalled)
    }

    func test_FromGameOverScreen() {
        gameOverTransition.fromGameOverScreen()
        let asteroids = engine.getNodeList(nodeClassType: AsteroidCollisionNode.self)
        XCTAssertNil(asteroids.head)
        for entityName: EntityName in [.hud, .gameOver, .hyperspacePowerUp, .torpedoPowerUp] {
            XCTAssertNil(engine.findEntity(named: entityName))
        }
    }

    func test_ToGameOverScreen() {
        gameOverTransition.toGameOverScreen()
        guard let gameOverEntity = engine.findEntity(named: .gameOver) else {
            XCTFail("gameOverEntity was nil")
            return
        }
        XCTAssertTrue(gameOverEntity.has(componentClassName: GameOverComponent.name))
        XCTAssertTrue(gameOverEntity.has(componentClassName: DisplayComponent.name))
        XCTAssertTrue(gameOverEntity.has(componentClassName: PositionComponent.name))
        XCTAssertTrue(gameOverEntity.has(componentClassName: TouchableComponent.name))
        XCTAssertTrue(gameOverEntity.has(componentClassName: GameStateComponent.name))
        guard let display = gameOverEntity[DisplayComponent.self]
        else {
            XCTFail("display was nil")
            return
        }
        XCTAssertNotNil(display.sknode)
    }
}
