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

final class GameOverTransition: GameOverUseCase {
    let engine: Engine
    let alertPresenter: PauseAlertPresenting
    var gameSize: CGSize {
        engine.gameStateComponent.gameSize
    }

    init(engine: Engine, alert: PauseAlertPresenting) {
        self.engine = engine
        self.alertPresenter = alert
    }

    func fromGameOverScreen() {
        alertPresenter.home() //HACK
    }

    func toGameOverScreen() {
        let gameOverView = GameOverView(gameSize: gameSize, hitPercent: engine.gameStateComponent.hitPercentage)
        gameOverView.name = "gameOverView"
        let gameOverEntity = Entity(named: .gameOver)
                .add(component: ButtonComponent())
                .add(component: ButtonGameOverToHomeComponent())
                .add(component: TouchableComponent())
                .add(component: HapticFeedbackComponent.shared)
                .add(component: GameOverComponent())
                .add(component: DisplayComponent(sknode: gameOverView))
                .add(component: PositionComponent(x: gameSize.width / 2,
                                                  y: gameSize.height / 2,
                                                  z: .gameOver,
                                                  rotationDegrees: 0))
                .add(component: engine.gameStateComponent)
        gameOverView.entity = gameOverEntity
        engine.add(entity: gameOverEntity)
    }
}
