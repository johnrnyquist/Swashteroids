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
        engine.gameStateComponent.gameSize
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
        engine.gameStateComponent.resetPlaying()
    }

    func toGameOverScreen() {
        let gameOverView = GameOverView(gameSize: gameSize, hitPercent: engine.gameStateComponent.hitPercentage)
        gameOverView.name = "gameOverView"
        let gameOverEntity = Entity(named: .gameOver)
                .add(component: GameOverComponent())
                .add(component: ButtonGameOverToHomeComponent())
                .add(component: DisplayComponent(sknode: gameOverView))
                .add(component: PositionComponent(x: gameSize.width / 2,
                                                  y: gameSize.height / 2,
                                                  z: .gameOver,
                                                  rotationDegrees: 0))
                .add(component: engine.gameStateComponent)
                .add(component: TouchableComponent())
                .add(component: ButtonComponent())
                .add(component: HapticFeedbackComponent.shared)
        gameOverView.entity = gameOverEntity
        engine.add(entity: gameOverEntity)
    }
}
