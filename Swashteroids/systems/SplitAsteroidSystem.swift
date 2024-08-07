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

final class SplitAsteroidSystem: ListIteratingSystem {
    let asteroidCreator: AsteroidCreatorUseCase
    let treasureCreator: TreasureCreatorUseCase
    let randomness: Randomizing
    let scaleManager: ScaleManaging

    init(asteroidCreator: AsteroidCreatorUseCase,
         treasureCreator: TreasureCreatorUseCase,
         randomness: Randomizing = Randomness.shared,
         scaleManager: ScaleManaging = ScaleManager.shared
    ) {
        self.asteroidCreator = asteroidCreator
        self.treasureCreator = treasureCreator
        self.randomness = randomness
        self.scaleManager = scaleManager
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
    private func splitAsteroid(asteroidEntity: Entity, splits: Int = 2, level: Int) {
        guard let radius = asteroidEntity[CollidableComponent.self]?.radius,
              let asteroidComponent = asteroidEntity[AsteroidComponent.self],
              let point = asteroidEntity[PositionComponent.self]?.point else { return }
        // Create treasure if the asteroid contains treasure info
        if let treasureInfo = asteroidEntity[TreasureInfoComponent.self] {
            treasureCreator.createTreasure(at: point, using: treasureInfo)
        }
        // Handle splitting based on asteroid size
        switch asteroidComponent.size {
            case .small:
                // No splitting for small asteroids
                break
            case .medium, .large:
                splitMediumOrLargeAsteroid(radius: radius,
                                           point: point,
                                           asteroidComponent: asteroidComponent,
                                           splits: splits,
                                           level: level)
        }
        // Add explosion effect
        addExplosionEffect(to: asteroidEntity)
    }

    private func splitMediumOrLargeAsteroid(radius: Double, point: CGPoint, asteroidComponent: AsteroidComponent, splits: Int, level: Int) {
        var asteroids = [Entity]()
        for _ in 1...splits {
            let newAsteroid = asteroidCreator.createAsteroid(
                radius: radius / scaleManager.SCALE_FACTOR / 2.0,
                x: point.x + randomness.nextDouble(from: -5.0, through: 5.0),
                y: point.y + randomness.nextDouble(from: -5.0, through: 5.0),
                size: asteroidComponent.shrink(),
                level: level
            )
            asteroids.append(newAsteroid)
        }
        adjustAsteroidVelocities(asteroids: asteroids)
    }

    private func adjustAsteroidVelocities(asteroids: [Entity]) {
        guard asteroids.count >= 2,
              let velocity1 = asteroids[0][VelocityComponent.self],
              let velocity2 = asteroids[1][VelocityComponent.self] else { return }
        // If the asteroids are moving in the same direction, change one of them
        if velocity1.linearVelocity.x.sign == velocity2.linearVelocity.x.sign {
            velocity2.x = -velocity2.x
        }
    }

    private func addExplosionEffect(to asteroidEntity: Entity) {
        if let emitter = SKEmitterNode(fileNamed: "shipExplosion.sks") {
            asteroidEntity
                    .remove(componentClass: DisplayComponent.self)
                    .remove(componentClass: CollidableComponent.self)
            let skNode = SKNode()
            skNode.name = "explosion on \(asteroidEntity.name)"
            skNode.addChild(emitter)
            asteroidEntity
                    .add(component: AudioComponent(asset: .explosion))
                    .add(component: DisplayComponent(sknode: skNode))
                    .add(component: DeathThroesComponent(countdown: 0.2))
        }
    }
}
