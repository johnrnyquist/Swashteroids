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

class CreatorsManager {
    let alienCreator: AlienCreatorUseCase
    let asteroidCreator: AsteroidCreatorUseCase
    let hudCreator: HudCreatorUseCase
    let powerUpCreator: PowerUpCreatorUseCase
    let shipButtonControlsCreator: ShipButtonControlsCreatorUseCase
    let shipControlQuadrantsCreator: QuadrantsControlsCreatorUseCase
    let shipCreator: PlayerCreatorUseCase
    let toggleShipControlsCreator: ToggleShipControlsCreatorUseCase
    let torpedoCreator: TorpedoCreatorUseCase
    let treasureCreator: TreasureCreatorUseCase
    let startScreenCreator: StartScreenCreatorUseCase

    init(engine: Engine, gameSize: CGSize, alertPresenter: PauseAlertPresenting, scene: GameScene) {
        alienCreator = AlienCreator(scene: scene, engine: engine, size: gameSize)
        asteroidCreator = AsteroidCreator(engine: engine)
        hudCreator = HudCreator(engine: engine, alertPresenter: alertPresenter)
        powerUpCreator = PowerUpCreator(engine: engine, size: gameSize)
        shipButtonControlsCreator = ShipButtonControlsCreator(engine: engine, size: gameSize)
        shipControlQuadrantsCreator = QuadrantsControlsCreator(engine: engine, size: gameSize)
        shipCreator = PlayerCreator(engine: engine, size: gameSize)
        toggleShipControlsCreator = ToggleShipControlsCreator(engine: engine, size: gameSize)
        torpedoCreator = TorpedoCreator(engine: engine)
        treasureCreator = TreasureCreator(engine: engine)
        startScreenCreator = StartScreenCreator(engine: engine, gameSize: gameSize)
    }
}
