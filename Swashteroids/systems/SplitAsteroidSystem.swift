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
    let splits: Int

    init(level: Int, splits: Int = 2) {
        self.level = level
        self.splits = splits
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
        splitAsteroid(asteroidEntity: entity, splits: spiltAsteroidComponent.splits, level: spiltAsteroidComponent.level)
        entity.remove(componentClass: SplitAsteroidComponent.self)
    }

    // What if the phaser splits things differently? Straight line cut? Wobbling after? Or results in just one smaller?
    // Or splits into 3 (two small, one medium)? What if it destroys a medium sized one?
    func splitAsteroid(asteroidEntity: Entity, splits: Int = 2, level: Int) {
        guard let collisionComponent = asteroidEntity[CollidableComponent.self],
              let asteroidComponent = asteroidEntity[AsteroidComponent.self],
              let positionComponent = asteroidEntity[PositionComponent.self]
        else { return }
        if randomness.nextInt(from: 1, through: 3) == 3 {
            creator.createTreasure(positionComponent: positionComponent)
        }
        switch asteroidComponent.size {
        case .small:
            break
        case .medium, .large:
            // The smallest asteroid is 1/4 the size of the large asteroid.
            for _ in 1...splits {
                // The new asteroid will be half the size of the original.
                creator.createAsteroid(radius: collisionComponent.radius * 1.0 / creator.scaleManager.SCALE_FACTOR / 2.0,
                                       x: positionComponent.x + randomness.nextDouble(from: -5.0, through: 5.0),
                                       y: positionComponent.y + randomness.nextDouble(from: -5.0, through: 5.0),
                                       size: asteroidComponent.shrink(),
                                       level: level)
            }
        }
        if let emitter = SKEmitterNode(fileNamed: "shipExplosion.sks") {
            asteroidEntity
                    .remove(componentClass: DisplayComponent.self)
                    .remove(componentClass: CollidableComponent.self)
            let skNode = SKNode()
            skNode.name = "explosion on \(asteroidEntity.name)"
            skNode.addChild(emitter)
            asteroidEntity
                    .add(component: AudioComponent(fileNamed: .explosion,
                                                   actionKey: asteroidEntity.name))
                    .add(component: DisplayComponent(sknode: skNode))
                    .add(component: DeathThroesComponent(countdown: 0.2))
        }
    }
}