//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import Swash
import SpriteKit

class CreatorManager {
    let alienCreator: AlienCreatorUseCase
    let asteroidCreator: AsteroidCreatorUseCase
    let hudCreator: HudCreatorUseCase
    let powerUpCreator: PowerUpCreatorUseCase
    let shipButtonControlsCreator: ShipButtonControlsCreatorUseCase
    let shipControlQuadrantsCreator: ShipQuadrantsControlsCreatorUseCase
    let shipCreator: ShipCreatorUseCase
    let toggleShipControlsCreator: ToggleShipControlsCreatorUseCase
    let torpedoCreator: TorpedoCreatorUseCase
    let treasureCreator: TreasureCreatorUseCase

    init(engine: Engine, gameSize: CGSize, alertPresenter: AlertPresenting, generator: UIImpactFeedbackGenerator) {
        alienCreator = AlienCreator(engine: engine, size: gameSize)
        asteroidCreator = AsteroidCreator(engine: engine)
        hudCreator = HudCreator(engine: engine, alertPresenter: alertPresenter)
        powerUpCreator = PowerUpCreator(engine: engine, size: gameSize)
        shipButtonControlsCreator = ShipButtonControlsCreator(engine: engine, size: gameSize, generator: generator)
        shipControlQuadrantsCreator = ShipQuadrantsControlsCreator(engine: engine, size: gameSize, generator: generator)
        shipCreator = ShipCreator(engine: engine, size: gameSize)
        toggleShipControlsCreator = ToggleShipControlsCreator(engine: engine, size: gameSize, generator: generator)
        torpedoCreator = TorpedoCreator(engine: engine)
        treasureCreator = TreasureCreator(engine: engine)
    }
}
