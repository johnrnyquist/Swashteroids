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

protocol AlienCreator: AnyObject {
    func createAliens(scene: GameScene)
}

protocol AsteroidCreator: AnyObject {
    func createAsteroid(radius: Double, x: Double, y: Double, level: Int)
}

protocol HudCreator: AnyObject {
    func createHud(gameState: AppStateComponent)
}

protocol PowerUpCreator: AnyObject {
    func createHyperspacePowerUp(level: Int)
    func createHyperspacePowerUp(level: Int, radius: Double)
    func createTorpedoesPowerUp(level: Int)
    func createTorpedoesPowerUp(level: Int, radius: Double)
}

protocol ShipCreator: AnyObject {
    func createShip(_ state: AppStateComponent)
    func destroy(ship: Entity)
}

protocol TorpedoCreator: AnyObject {
    func createTorpedo(_ gunComponent: GunComponent, _ position: PositionComponent, _ velocity: VelocityComponent)
}

protocol TreasureCreator: AnyObject {
    func createTreasure(positionComponent: PositionComponent)
}

