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

extension Engine {
    func clearEntities(of nodeType: Node.Type?) {
        guard let nodeType = nodeType else { return }
        let nodes = getNodeList(nodeClassType: nodeType)
        var node = nodes.head
        while let currentNode = node {
            remove(entity: currentNode.entity!)
            node = currentNode.next
        }
    }
}

extension Transition {

    func fromGameOverScreen() {
        // Clear any existing treasures, aliens, and asteroids. 
        [TreasureCollisionNode.self, AlienCollisionNode.self, AsteroidCollisionNode.self].forEach { engine.clearEntities(of: $0) }
        // Clear entities with unique names.
        engine.removeEntities(named: [.hud, .gameOver, .hyperspacePowerUp, .torpedoPowerUp, .pauseButton])
        if let appState = engine.appState?[AppStateComponent.name] as? AppStateComponent {
            appState.resetGame()
        }
    }

    func toGameOverScreen() {
        guard let appStateComponent = engine.appState?[AppStateComponent.name] as? AppStateComponent else {
            fatalError("WARNING: engine did not contain AppStateComponent!")
        }
        let gameOverView = GameOverView(gameSize: gameSize, hitPercent: appStateComponent.hitPercentage)
        gameOverView.name = "gameOverView"
        let gameOverEntity = Entity(named: .gameOver)
                .add(component: GameOverComponent())
                .add(component: DisplayComponent(sknode: gameOverView))
                .add(component: PositionComponent(x: gameSize.width / 2, y: gameSize.height / 2, z: .gameOver, rotationDegrees: 0))
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
