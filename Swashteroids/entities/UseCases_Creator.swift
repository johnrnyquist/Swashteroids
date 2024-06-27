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
    func createAliens(scene: GameScene)
}

protocol AsteroidCreatorUseCase: AnyObject {
    func createAsteroid(radius: Double, x: Double, y: Double, size: AsteroidSize, level: Int)
}

protocol HudCreatorUseCase: AnyObject {
    func createHud(gameState: SwashteroidsStateComponent)
}

protocol PowerUpCreatorUseCase: AnyObject {
    func createHyperspacePowerUp(level: Int)
    func createHyperspacePowerUp(level: Int, radius: Double)
    func createTorpedoesPowerUp(level: Int)
    func createTorpedoesPowerUp(level: Int, radius: Double)
}

protocol ShipButtonControlsCreatorUseCase: AnyObject {
    func createShipControlButtons()
    func enableShipControlButtons()
    func removeShipControlButtons()
    func showFireButton()
    func showHyperspaceButton()
}

protocol ShipCreatorUseCase: AnyObject {
    func createShip(_ state: SwashteroidsStateComponent)
    func destroy(ship: Entity)
}

protocol ShipQuadrantsControlsCreatorUseCase: AnyObject {
    func createShipControlQuadrants()
    func removeShipControlQuadrants()
}

protocol ToggleShipControlsCreatorUseCase: AnyObject {
    func createToggleButton(_ toggleState: Toggle)
    func removeToggleButton()
}

protocol TorpedoCreatorUseCase: AnyObject {
    func createTorpedo(_ gunComponent: GunComponent, _ position: PositionComponent, _ velocity: VelocityComponent)
}

protocol TreasureCreatorUseCase: AnyObject {
    func createTreasure(positionComponent: PositionComponent)
}
