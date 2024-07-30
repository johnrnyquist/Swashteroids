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

final class CreatorsManager {
    let alienCreator: AlienCreatorUseCase
    let asteroidCreator: AsteroidCreatorUseCase
    let hudCreator: HudCreatorUseCase
    let playerCreator: PlayerCreatorUseCase
    let powerUpCreator: PowerUpCreatorUseCase
    let shipButtonControlsCreator: ShipButtonCreatorUseCase
    let shipControlQuadrantsCreator: QuadrantsControlsCreatorUseCase
    let startScreenCreator: StartScreenCreatorUseCase
    let toggleShipControlsCreator: ToggleShipControlsCreatorUseCase
    let torpedoCreator: TorpedoCreatorUseCase
    let treasureCreator: TreasureCreatorUseCase

    init(engine: Engine, gameSize: CGSize, alertPresenter: PauseAlertPresenting, scene: GameScene) {
        startScreenCreator = StartScreenCreator(engine: engine, gameSize: gameSize)
        alienCreator = AlienCreator(scene: scene, engine: engine, size: gameSize)
        hudCreator = HudCreator(engine: engine, alertPresenter: alertPresenter)
        powerUpCreator = PowerUpCreator(engine: engine, size: gameSize)
        shipButtonControlsCreator = ShipButtonsCreator(engine: engine, size: gameSize)
        shipControlQuadrantsCreator = QuadrantsControlsCreator(engine: engine, size: gameSize)
        playerCreator = PlayerCreator(engine: engine, size: gameSize)
        toggleShipControlsCreator = ToggleShipControlsCreator(engine: engine, size: gameSize)
        torpedoCreator = TorpedoCreator(engine: engine)
        treasureCreator = TreasureCreator(engine: engine)
        asteroidCreator = AsteroidCreator(engine: engine, treasureCreator: treasureCreator)
    }
}
