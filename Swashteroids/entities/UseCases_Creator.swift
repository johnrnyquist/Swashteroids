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

protocol SplitAsteroidUseCase: AnyObject {
    func createTreasure(positionComponent: PositionComponent)
    func createAsteroid(radius: Double, x: Double, y: Double, size: AsteroidSize, level: Int)
    var scaleManager: any ScaleManaging { get }
}

protocol AlienCreatorUseCase: AnyObject {
    func createAliens(scene: GameScene)
}

protocol AsteroidCreatorUseCase: AnyObject {
    func createAsteroid(radius: Double, x: Double, y: Double, size: AsteroidSize, level: Int)
}

protocol HudCreatorUseCase: AnyObject {
    func createHud(gameState: AppStateComponent)
}

protocol PowerUpCreatorUseCase: AnyObject {
    func createHyperspacePowerUp(level: Int)
    func createHyperspacePowerUp(level: Int, radius: Double)
    func createTorpedoesPowerUp(level: Int)
    func createTorpedoesPowerUp(level: Int, radius: Double)
}

protocol ShipCreatorUseCase: AnyObject {
    func createShip(_ state: AppStateComponent)
    func destroy(ship: Entity)
}

protocol TorpedoCreatorUseCase: AnyObject {
    func createTorpedo(_ gunComponent: GunComponent, _ position: PositionComponent, _ velocity: VelocityComponent)
}

protocol TreasureCreatorUseCase: AnyObject {
    func createTreasure(positionComponent: PositionComponent)
}

