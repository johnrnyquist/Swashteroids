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

class GameOverTransition: GameOverUseCase {
    let engine: Engine
    let generator: UIImpactFeedbackGenerator?
    var gameSize: CGSize {
        engine.appStateComponent.gameSize
    }

    init(engine: Engine, generator: UIImpactFeedbackGenerator?) {
        self.engine = engine
        self.generator = generator
    }

    func fromGameOverScreen() {
        // Clear any existing treasures, aliens, and asteroids. 
        [TreasureCollisionNode.self, AlienCollisionNode.self, AsteroidCollisionNode.self].forEach { engine.clearEntities(of: $0) }
        // Clear entities with unique names.
        engine.removeEntities(named: [.hud, .gameOver, .hyperspacePowerUp, .torpedoPowerUp, .pauseButton])
        engine.appStateComponent.resetGame()
    }

    func toGameOverScreen() {
        let gameOverView = GameOverView(gameSize: gameSize, hitPercent: engine.appStateComponent.hitPercentage)
        gameOverView.name = "gameOverView"
        let gameOverEntity = Entity(named: .gameOver)
                .add(component: GameOverComponent())
                .add(component: DisplayComponent(sknode: gameOverView))
                .add(component: PositionComponent(x: gameSize.width / 2,
                                                  y: gameSize.height / 2,
                                                  z: .gameOver,
                                                  rotationDegrees: 0))
                .add(component: TouchableComponent())
                .add(component: engine.appStateComponent)
                .add(component: ButtonBehaviorComponent(
                    touchDown: { [unowned self] sprite in
                        generator?.impactOccurred()
                        engine.appStateEntity
                              .add(component: TransitionAppStateComponent(from: .gameOver, to: .start))
                    }))
        gameOverView.entity = gameOverEntity
        engine.add(entity: gameOverEntity)
    }
}
