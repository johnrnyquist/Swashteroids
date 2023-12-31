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
        while let currentNode = asteroid {
            engine.remove(entity: currentNode.entity!)
            asteroid = currentNode.next
        }
        engine.removeEntities(named: [.hud, .gameOver, .hyperspacePowerUp, .torpedoPowerUp])
        if let appState = engine.appState?[AppStateComponent.name] as? AppStateComponent {
            appState.reset()
        }
    }

    func toGameOverScreen() {
        guard let appStateComponent = engine.appState?[AppStateComponent.name] as? AppStateComponent else {
            fatalError("WARNING: engine did not contain AppStateComponent!")
        }
        let gameOverView = GameOverView(size: size)
        let gameOverEntity = Entity(named: .gameOver)
                .add(component: GameOverComponent())
                .add(component: DisplayComponent(sknode: gameOverView))
				.add(component: PositionComponent(x: size.width/2, y: size.height/2, z: .top, rotationDegrees: 0))
                .add(component: TouchableComponent())
                .add(component: appStateComponent)
                .add(component: ButtonBehaviorComponent(
                    touchDown: { [unowned self] sprite in
                        generator?.impactOccurred()
                        engine.appState?
                              .add(component: TransitionAppStateComponent(from: .gameOver, to: .start))
                    }))
        gameOverView.entity = gameOverEntity
        do {
            try engine.add(entity: gameOverEntity)
        } catch {
            print(#function, #line, "WARNING: engine already contained \(gameOverEntity.name) entity!")
        }
    }
}
