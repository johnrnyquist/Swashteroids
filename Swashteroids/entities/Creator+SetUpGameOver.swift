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

extension Creator {
    func tearDownGameOver() {
        // Clear any existing asteroids
        let asteroids = engine.getNodeList(nodeClassType: AsteroidCollisionNode.self)
        let gameOverNodes = engine.getNodeList(nodeClassType: GameOverNode.self)
        let gameOverNode = gameOverNodes.head
        var asteroid = asteroids.head
        while asteroid != nil {
            destroyEntity(asteroid!.entity!)
            asteroid = asteroid?.next
        }
        if let hud = engine.hud,
           let gameOverNode,
           let entity = gameOverNode.entity {
            engine.removeEntity(entity: entity)
            engine.removeEntity(entity: hud)
            if let powerUp = engine.getEntity(named: .plasmaTorpedoesPowerUp) {
                engine.removeEntity(entity: powerUp)
            }
        }
    }

    func setUpGameOver() {
        let gameOverView = GameOverView(size: size)
        let gameOverEntity = Entity(name: .gameOver)
                .add(component: GameOverComponent())
                .add(component: DisplayComponent(sknode: gameOverView))
                .add(component: PositionComponent(x: 0, y: 0, z: .top, rotation: 0))
                .add(component: TouchableComponent())
                .add(component: appStateEntity.get(componentClassName: AppStateComponent.name) as! AppStateComponent)
                .add(component: ButtonBehaviorComponent(
                    touchDown: { [unowned self] sprite in
                        generator.impactOccurred()
                        appStateEntity
                                .add(component: TransitionAppStateComponent(to: .start, from: .gameOver))
                    }))
        gameOverView.entity = gameOverEntity
        engine.replaceEntity(entity: gameOverEntity)
    }
}