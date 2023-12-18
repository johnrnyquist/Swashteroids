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
import SpriteKit
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
		appStateComponent = AppStateComponent(size: .zero,
											  ships: 3,
											  level: 4,
											  score: 5,
											  appState: .infoButtons,
											  shipControlsState: .hidingButtons)
		appStateEntity = Entity(name: "appStateEntity")
			.add(component: appStateComponent)
		do {
			try engine.addEntity(entity: appStateEntity)
		} catch {
			XCTFail("Failed to add appStateEntity")
		}
		creator = MockCreator()
		transition = MockTransition(engine: engine,
									hudManager: creator,
									toggleButtonsManager: creator,
									shipControlQuadrantsManager: creator,
									shipControlButtonsManager: creator)
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
			XCTAssertNotNil(engine.getEntity(named: entityName))
		}
	}

	func test_FromStartScreen() {
		transition.fromStartScreen()
		for entityName: EntityName in [.start, .noButtons, .withButtons] {
			XCTAssertNil(engine.getEntity(named: entityName))
		}
	}

	//TODO: This test is fragile, it depends on the the calls .
	func test_ToPlayingScreenWhileHidingButtons() {
		transition.toPlayingScreen(with: .hidingButtons)
		// I could mock appStateComponent, but it's pretty lightweight.
		XCTAssertEqual(appStateComponent.numShips, 3)
		XCTAssertEqual(appStateComponent.level, 0)
		XCTAssertEqual(appStateComponent.score, 0)
		XCTAssertTrue(creator.createHudCalled)
		XCTAssertTrue(creator.createToggleButtonCalled)
		XCTAssertTrue(creator.createShipControlQuadrantsCalled)
	}

	//TODO: This test is fragile, it depends on the the calls
	func test_ToPlayingScreenWhileShowingButtons() {
		transition.toPlayingScreen(with: .showingButtons)
		// I could mock appStateComponent, but it's pretty lightweight.
		XCTAssertEqual(appStateComponent.numShips, 3)
		XCTAssertEqual(appStateComponent.level, 0)
		XCTAssertEqual(appStateComponent.score, 0)
		XCTAssertTrue(creator.createHudCalled)
		XCTAssertTrue(creator.createToggleButtonCalled)
		XCTAssertTrue(creator.enableShipControlButtonsCalled)
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
		for entityName: EntityName in [.hud, .gameOver, .hyperspacePowerUp, .plasmaTorpedoesPowerUp] {
			XCTAssertNil(engine.getEntity(named: entityName))
		}
		XCTAssertEqual(appStateComponent.numShips, 3)
		XCTAssertEqual(appStateComponent.level, 0)
		XCTAssertEqual(appStateComponent.score, 0)
	}

	func test_ToGameOverScreen() {
		transition.toGameOverScreen()
		guard let gameOverEntity = engine.getEntity(named: .gameOver) else {
			XCTFail("gameOverEntity was nil")
			return
		}
		XCTAssertTrue(gameOverEntity.has(componentClassName: GameOverComponent.name))
		XCTAssertTrue(gameOverEntity.has(componentClassName: DisplayComponent.name))
		XCTAssertTrue(gameOverEntity.has(componentClassName: PositionComponent.name))
		XCTAssertTrue(gameOverEntity.has(componentClassName: TouchableComponent.name))
		XCTAssertTrue(gameOverEntity.has(componentClassName: AppStateComponent.name))
		XCTAssertTrue(gameOverEntity.has(componentClassName: ButtonBehaviorComponent.name))
		guard let display = gameOverEntity.get(componentClassName: DisplayComponent.name) as? DisplayComponent
		else {
			XCTFail("display was nil")
			return
		}
		XCTAssertNotNil(display.sknode)
	}
}

fileprivate class MockTransition: Transition {
	init(engine: Engine, hudManager: MockCreator, toggleButtonsManager: MockCreator, shipControlQuadrantsManager: MockCreator, shipControlButtonsManager: MockCreator) {
		super.init(engine: engine, creator: Creator(engine: Engine(), size: .zero))
		self.hudManager = hudManager
		self.toggleButtonsManager = toggleButtonsManager
		self.shipControlQuadrantsManager = shipControlQuadrantsManager
		self.shipControlButtonsManager = shipControlButtonsManager
	}
}

class MockCreator: HudManager, ToggleButtonManager, ShipControlQuadrantsManager, ShipControlButtonsManager {
	var createHudCalled = false
	var createToggleButtonCalled = false
	var removeToggleButtonCalled = false
	var createShipControlQuadrantsCalled = false
	var removeShipControlQuadrantsCalled = false
	var enableShipControlButtonsCalled = false
	var removeShipControlButtonsCalled = false
	var createShipControlButtonsCalled = false

	func createHud(gameState: AppStateComponent) {
		createHudCalled = true
	}

	func createToggleButton(_ state: Toggle) {
		createToggleButtonCalled = true
	}

	func removeToggleButton() {
		removeToggleButtonCalled = true
	}

	func createShipControlQuadrants() {
		createShipControlQuadrantsCalled = true
	}

	func removeShipControlQuadrants() {
		removeShipControlQuadrantsCalled = true
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

