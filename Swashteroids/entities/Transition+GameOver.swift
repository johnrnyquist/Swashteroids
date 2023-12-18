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


extension Transition {
    func fromGameOverScreen() {
        // Clear any existing asteroids
        let asteroids = engine.getNodeList(nodeClassType: AsteroidCollisionNode.self)
        var asteroid = asteroids.head
        while asteroid != nil {
            engine.removeEntity(entity: asteroid!.entity!)
            asteroid = asteroid?.next
        }
        engine.removeEntities(named: [.hud, .gameOver, .hyperspacePowerUp, .plasmaTorpedoesPowerUp])
        if let appState = engine.appState?[AppStateComponent.name] as? AppStateComponent {
            appState.reset()
        }
    }

    func toGameOverScreen() {
        guard let appStateComponent = engine.appState?[AppStateComponent.name] as? AppStateComponent else {
            print("WARNING: engine did not contain AppStateComponent!")
            return
        }
        let gameOverView = GameOverView(size: size)
        let gameOverEntity = Entity(name: .gameOver)
                .add(component: GameOverComponent())
                .add(component: DisplayComponent(sknode: gameOverView))
                .add(component: PositionComponent(x: 0, y: 0, z: .top, rotation: 0))
                .add(component: TouchableComponent())
                .add(component: appStateComponent)
                .add(component: ButtonBehaviorComponent(
                    touchDown: { [unowned self] sprite in
                        generator.impactOccurred()
                        engine.appState?
                              .add(component: TransitionAppStateComponent(to: .start, from: .gameOver))
                    }))
        gameOverView.entity = gameOverEntity
        do {
            try engine.addEntity(entity: gameOverEntity)
        } catch {
            print("WARNING: engine already contained \(gameOverEntity.name) entity!")
        }
    }
}