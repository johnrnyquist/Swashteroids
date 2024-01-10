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

extension Creator: AlienCreator {
    func createAlien() {
        guard engine.getEntity(named: .ship) != nil else { return }
        guard engine.getEntity(named: .alien) == nil else { return }
        numAliens += 1
        let sprite = SwashSpriteNode(imageNamed: .alien)
        let alienComponent = AlienComponent(reactionTime: Double.random(in: 0.4...0.8))
        let left = CGPoint(x: -sprite.width / 2,
                           y: Double.random(in: 40...(size.height - 40)))
        let right = CGPoint(x: size.width + sprite.width / 2,
                            y: Double.random(in: 40...(size.height - 40)))
        switch Bool.random() {
            case true:
                alienComponent.startDestination = left
                alienComponent.endDestination = right
            case false:
                alienComponent.startDestination = right
                alienComponent.endDestination = left
        }
        let velocityX = Double.random(in: -10.0...30.0) + 60.0
        let alien = Entity(named: .alien + "_\(numAliens)")
            .add(component: alienComponent)
            .add(component: CollisionComponent(radius: 25))
            .add(component: PositionComponent(x: alienComponent.startDestination.x,
                                              y: alienComponent.startDestination.y,
                                              z: .asteroids))
            .add(component: VelocityComponent(velocityX: velocityX, velocityY: 0, wraps: false, base: velocityX))
            .add(component: AudioComponent(fileNamed: .alienEntrance, actionKey: "alienEntrance"))
            .add(component: GunComponent(offsetX: 21,
                                         offsetY: 0,
                                         minimumShotInterval: 2,
                                         torpedoLifetime: 2,
                                         torpedoColor: .white,
                                         ownerType: .computerOpponent))
            .add(component: FireDownComponent.shared)
            .add(component: DisplayComponent(sknode: sprite))
        try? engine.add(entity: alien)
        print(engine.entities)
    }
}
