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

protocol AlienCreatorUseCase: AnyObject {
    func createAliens()
}

protocol AsteroidCreatorUseCase: AnyObject {
    @discardableResult
    func createAsteroid(radius: Double, x: Double, y: Double, size: AsteroidSize, level: Int) -> Entity
}

protocol HudCreatorUseCase: AnyObject {
    func createHud(gameState: GameStateComponent)
}

protocol PowerUpCreatorUseCase: AnyObject {
    func createPowerUp(level: Int, type: PowerUpType, avoiding point: CGPoint?)
    func createPowerUp(level: Int, type: PowerUpType)
}

protocol ShipButtonCreatorUseCase: AnyObject {
    func createThrustButton()
    func createLeftButton()
    func createRightButton()
    func createFlipButton()
    func createFireButton()
    func createHyperspaceButton()
    
    func createShipControlButtons()
    func enableShipControlButtons()
    func removeShipControlButtons()
    func showFireButton()
    func showHyperspaceButton()
}

protocol PlayerCreatorUseCase: AnyObject {
    func createPlayer(_ state: GameStateComponent)
    func destroy(entity: Entity)
}

protocol QuadrantsControlsCreatorUseCase: AnyObject {
    func createQuadrantControls()
    func removeQuadrantControls()
}

protocol ToggleShipControlsCreatorUseCase: AnyObject {
    func createToggleButton(_ toggleState: Toggle)
    func removeToggleButton()
}

protocol TorpedoCreatorUseCase: AnyObject {
    func createTorpedo(_ gunComponent: GunComponent, _ position: PositionComponent, _ velocity: VelocityComponent)
}

protocol TreasureCreatorUseCase: AnyObject {
    func createTreasure(at point: CGPoint, using treasureInfo: TreasureInfoComponent)
}

protocol StartScreenCreatorUseCase: AnyObject {
    func createGamepadIndicator()
    func createStartButtons()
    func createStartScreen()
    func removeGamepadIndicator()
    func removeStartButtons()
    func removeStartScreen()
}
