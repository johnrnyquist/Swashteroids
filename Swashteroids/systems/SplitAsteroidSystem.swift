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
import Foundation
import SpriteKit

class SplitAsteroidComponent: Component {
    let level: Int

    init(level: Int) {
        self.level = level
        super.init()
    }
}

class SplitAsteroidNode: Node {
    required init() {
        super.init()
        components = [
            SplitAsteroidComponent.name: nil_component,
            AsteroidComponent.name: nil_component,
            PositionComponent.name: nil_component,
            VelocityComponent.name: nil_component
        ]
    }
}

class SplitAsteroidSystem: ListIteratingSystem {
    let creator: Creator
    let randomness: Randomness

    init(creator: Creator, randomness: Randomness) {
        self.creator = creator
        self.randomness = randomness
        super.init(nodeClass: SplitAsteroidNode.self)
        nodeUpdateFunction = updateNode
    }

    func updateNode(node: Node, time: TimeInterval) {
        guard let spiltAsteroidComponent = node[SplitAsteroidComponent.self],
              let entity = node.entity
        else { return }
        print("SpiltAsteroid level: \(spiltAsteroidComponent.level)")
        splitAsteroid(asteroidEntity: entity, splits: 2, level: spiltAsteroidComponent.level)
    }

    func splitAsteroid(asteroidEntity: Entity, splits: Int = 2, level: Int) {
        guard let collisionComponent = asteroidEntity[CollidableComponent.self],
              let positionComponent = asteroidEntity[PositionComponent.self]
        else { return }
        if randomness.nextInt(from: 1, through: 3) == 3 {
            creator.createTreasure(positionComponent: positionComponent)
        }
        if (collisionComponent.radius > LARGE_ASTEROID_RADIUS * creator.scaleManager.SCALE_FACTOR / 4) {
            for _ in 1...splits {
                creator.createAsteroid(radius: collisionComponent.radius * 1.0 / creator.scaleManager.SCALE_FACTOR / 2.0,
                                       x: positionComponent.x + randomness.nextDouble(from: -5.0, through: 5.0),
                                       y: positionComponent.y + randomness.nextDouble(from: -5.0, through: 5.0),
                                       level: level)
            }
        }
        if let emitter = SKEmitterNode(fileNamed: "shipExplosion.sks") {
            let skNode = SKNode()
            skNode.name = "explosion on \(asteroidEntity.name)"
            skNode.addChild(emitter)
            asteroidEntity
                    .remove(componentClass: DisplayComponent.self)
                    .remove(componentClass: CollidableComponent.self)
                    .add(component: AudioComponent(fileNamed: .explosion,
                                                   actionKey: asteroidEntity.name))
                    .add(component: DisplayComponent(sknode: skNode))
                    .add(component: DeathThroesComponent(countdown: 0.2))
        }
    }
}
