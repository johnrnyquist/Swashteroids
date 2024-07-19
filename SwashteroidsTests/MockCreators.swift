//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import Foundation
import Swash
@testable import Swashteroids

final class MockAlienCreator: AlienCreatorUseCase {
    func createAliens() {
    }
    
    var createAliensCalled = false

    func createAlienWorker(startDestination: CGPoint, endDestination: CGPoint) {
    }

    func createAlienSoldier(startDestination: CGPoint, endDestination: CGPoint) {
    }

    func createAliens(scene: GameScene) {
        createAliensCalled = true
    }
}

final class MockAsteroidCreator: AsteroidCreatorUseCase {
    var createAsteroidCalled = 0

    func createAsteroid(radius: Double, x: Double, y: Double, size: AsteroidSize, level: Int) {
        createAsteroidCalled += 1
    }
}

final class MockHudCreator: HudCreatorUseCase {
    func createHud(gameState: GameStateComponent) {
    }
}

final class MockShipButtonControlsCreator: ShipButtonControlsCreatorUseCase {
    func createShipControlButtons() {}

    func enableShipControlButtons() {}

    func removeShipControlButtons() {}

    func showFireButton() {}

    func showHyperspaceButton() {}
}

final class MockPlayerCreator: PlayerCreatorUseCase {
    var createShipCalled = false
    var destroyCalled = false

    func createPlayer(_ state: GameStateComponent) {
        createShipCalled = true
    }

    func destroy(entity: Entity) {
        destroyCalled = true
    }
}

final class MockQuadrantsButtonToggleCreator: QuadrantsControlsCreatorUseCase, ShipButtonControlsCreatorUseCase, ToggleShipControlsCreatorUseCase {
    //MARK: - ShipQuadrantsControlsManager
    var createShipControlQuadrantsCalled = false
    var removeShipControlQuadrantsCalled = false

    func removeQuadrantControls() {
        removeShipControlQuadrantsCalled = true
    }

    func createQuadrantControls() {
        createShipControlQuadrantsCalled = true
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

    func removeShipControlButtons() {
        removeShipControlButtonsCalled = true
    }

    func createShipControlButtons() {
        createShipControlButtonsCalled = true
    }

    func enableShipControlButtons() {
        enableShipControlButtonsCalled = true
    }

    //MARK: - ToggleShipControlsManager
    var createToggleButtonCalled = false
    var removeToggleButtonCalled = false

    func removeToggleButton() {
        removeToggleButtonCalled = true
    }

    func createToggleButton(_ toggleState: Toggle) {
        createToggleButtonCalled = true
    }
}
