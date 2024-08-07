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
    var createAliensCalled = false

    func createAliens() {
        createAliensCalled = true
    }
}

final class MockAsteroidCreator: AsteroidCreatorUseCase {
    var createAsteroidCalled = 0

    func createAsteroid(radius: Double, x: Double, y: Double, size: AsteroidSize, level: Int) -> Entity {
        createAsteroidCalled += 1
        return Entity()
    }
}

final class MockStartScreenCreator: StartScreenCreatorUseCase {
    func createGamepadIndicator() {}

    func createStartButtons() {}

    func createStartScreen() {}

    func removeGamepadIndicator() {}

    func removeStartButtons() {}

    func removeStartScreen() {}
}

final class MockHudCreator: HudCreatorUseCase {
    func createHud(gameState: GameStateComponent) {
    }
}

final class MockShipButtonControlsCreator: ShipButtonCreatorUseCase {
    func createThrustButton() {}

    func createLeftButton() {}

    func createRightButton() {}

    func createFlipButton() {}

    func createFireButton() {}

    func createHyperspaceButton() {}

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

final class MockQuadrantsButtonToggleCreator: QuadrantsControlsCreatorUseCase,
                                              ShipButtonCreatorUseCase,
                                              ToggleShipControlsCreatorUseCase,
                                              StartScreenCreatorUseCase {
    var createFireButtonCalled = false
    var createFlipButtonCalled = false
    var createGamepadIndicatorCalled = false
    var createHyperspaceButtonCalled = false
    var createLeftButtonCalled = false
    var createRightButtonCalled = false
    var createStartButtonsCalled = false
    var createStartScreenCalled = false
    var createThrustButtonCalled = false
    var removeGamepadIndicatorCalled = false
    var removeStartButtonsCalled = false
    var removeStartScreenCalled = false

    func createFireButton() { createFireButtonCalled = true }

    func createFlipButton() { createFlipButtonCalled = true }

    func createGamepadIndicator() { createGamepadIndicatorCalled = true }

    func createHyperspaceButton() { createHyperspaceButtonCalled = true }

    func createLeftButton() { createLeftButtonCalled = true }

    func createRightButton() { createRightButtonCalled = true }

    func createStartButtons() { createStartButtonsCalled = true }

    func createStartScreen() { createStartScreenCalled = true }

    func createThrustButton() { createThrustButtonCalled = true }

    func removeGamepadIndicator() { removeGamepadIndicatorCalled = true }

    func removeStartButtons() { removeStartButtonsCalled = true }

    func removeStartScreen() { removeStartScreenCalled = true }

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
