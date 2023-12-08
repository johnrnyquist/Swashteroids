//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import SpriteKit
import Swash

final class CollisionSystem: System {
    private weak var creator: Creator!
    private weak var appStateNodes: NodeList!
    private weak var ships: NodeList!
    private weak var asteroids: NodeList!
    private weak var bullets: NodeList!
    private weak var gunSuppliers: NodeList!

    init(_ creator: Creator) {
        self.creator = creator
    }

    override public func addToEngine(engine: Engine) {
        appStateNodes = engine.getNodeList(nodeClassType: AppStateNode.self)
        ships = engine.getNodeList(nodeClassType: ShipCollisionNode.self)
        asteroids = engine.getNodeList(nodeClassType: AsteroidCollisionNode.self)
        bullets = engine.getNodeList(nodeClassType: PlasmaTorpedoCollisionNode.self)
        gunSuppliers = engine.getNodeList(nodeClassType: GunSupplierNode.self)
    }

    /// 
    /// - Parameter time: The time since the last update
    override public func update(time: TimeInterval) {
        shipGunCollisionCheck()
        bulletAsteroidCollisionCheck()
        shipAsteroidCollisionCheck()
    }

    private func splitAsteroid(asteroidCollision: CollisionComponent, asteroidPosition: PositionComponent, asteroidCollisionNode: Node?, splits: Int = 2) {
        guard let asteroidCollisionNode else { return }
        if (asteroidCollision.radius > LARGE_ASTEROID_RADIUS / 4) {
            for _ in 1...splits {
                creator.createAsteroid(radius: asteroidCollision.radius / 2,
                                       x: asteroidPosition.position.x + Double.random(in: -5...5),
                                       y: asteroidPosition.position.y + Double.random(in: -5...5))
            }
        }
        let spriteNode = SKNode()
        if let emitter = SKEmitterNode(fileNamed: "shipExplosion.sks") {
            spriteNode.addChild(emitter)
            asteroidCollisionNode.entity?
                                 .remove(componentClass: DisplayComponent.self)
                                 .remove(componentClass: CollisionComponent.self)
                                 .add(component: DisplayComponent(sknode: spriteNode))
                                 .add(component: DeathThroesComponent(countdown: 0.2))
        }
    }

    func shipGunCollisionCheck() {
        let shipCollisionNode = ships.head
        var gunSupplierNode = gunSuppliers?.head
        while gunSupplierNode != nil {
            guard
                let gunSupplierPosition = gunSupplierNode?[PositionComponent.self],
                let shipPosition = shipCollisionNode?[PositionComponent.self],
                let gunSupplierCollision = gunSupplierNode?[CollisionComponent.self],
                let shipCollision = shipCollisionNode?[CollisionComponent.self],
                let sprite = gunSupplierNode?[DisplayComponent.self]?.sprite
            else { gunSupplierNode = gunSupplierNode?.next; continue }
            let distanceToShip = distance(gunSupplierPosition.position, shipPosition.position)
            if (distanceToShip <= gunSupplierCollision.radius + shipCollision.radius) {
                let bang = SKAction.playSoundFileNamed("fire.wav", waitForCompletion: false)
                sprite.scene?.run(bang)
                creator.removeEntity(gunSupplierNode!.entity!)
                gunSupplierNode = gunSupplierNode?.next
                shipCollisionNode?.entity?
                                  .add(component: GunComponent(offsetX: 21, offsetY: 0,
                                                               minimumShotInterval: 0.25,
                                                               torpedoLifetime: 2))
            }
            gunSupplierNode = gunSupplierNode?.next
        }
    }

    func bulletAsteroidCollisionCheck() {
        var bulletNode = bullets?.head
        var asteroidNode: Node?
        while bulletNode != nil {
            asteroidNode = asteroids?.head
            while asteroidNode != nil {
                guard
                    let audio = asteroidNode?[AudioComponent.self],
                    let asteroidPosition = asteroidNode?[PositionComponent.self],
                    let bulletPosition = bulletNode?[PositionComponent.self],
                    let asteroidCollision = asteroidNode?[CollisionComponent.self]
                else { asteroidNode = asteroidNode?.next; continue } // or return? }
                if (distance(asteroidPosition.position, bulletPosition.position) <= asteroidCollision.radius) {
                    let bang = SKAction.playSoundFileNamed("bangLarge.wav", waitForCompletion: false)
                    audio.addSoundAction(bang, withKey: asteroidNode!.entity!.name)
                    creator.removeEntity(bulletNode!.entity!)
                    splitAsteroid(asteroidCollision: asteroidCollision,
                                  asteroidPosition: asteroidPosition,
                                  asteroidCollisionNode: asteroidNode)
                    if let gameStateNode = appStateNodes.head,
                       let appStateComponent = gameStateNode[AppStateComponent.self] {
                        appStateComponent.score += 1
                    }
                    break
                }
                asteroidNode = asteroidNode?.next
            }
            bulletNode = bulletNode?.next
        }
    }

    func shipAsteroidCollisionCheck() {
        var shipCollisionNode = ships.head
        while shipCollisionNode != nil {
            var asteroidCollisionNode = asteroids.head
            while asteroidCollisionNode != nil {
                guard
                    let ship = shipCollisionNode?[ShipComponent.self].entity as? ShipEntity,
                    let asteroidPosition = asteroidCollisionNode?[PositionComponent.self],
                    let shipPosition = shipCollisionNode?[PositionComponent.self],
                    let asteroidCollision = asteroidCollisionNode?[CollisionComponent.self],
                    let shipCollision = shipCollisionNode?[CollisionComponent.self],
                    let audio = shipCollisionNode?[AudioComponent.self]
                else { asteroidCollisionNode = asteroidCollisionNode?.next; continue }
                let distanceToShip = distance(asteroidPosition.position, shipPosition.position)
                if (distanceToShip <= asteroidCollision.radius + shipCollision.radius) {
                    if let asteroidMotion = asteroidCollisionNode?[MotionComponent.self],
                       let shipMotion = shipCollisionNode?[MotionComponent.self] {
                        shipMotion.velocity = asteroidMotion.velocity
                        shipMotion.angularVelocity = asteroidMotion.angularVelocity
                    }
                    // If a ship hits an asteroid, it enters its death throes. Removing its ability to move or shoot.
                    // A ship in its death throes can still hit an asteroid. 
                    if ship.has(componentClassName: DeathThroesComponent.name) == false { //HACK not sure I like this check
                        ship.destroy(audio)
                        if let appState = appStateNodes.head,
                           let component = appState[AppStateComponent.self] {
                            component.ships -= 1
                        }
                    }
                    splitAsteroid(asteroidCollision: asteroidCollision,
                                  asteroidPosition: asteroidPosition,
                                  asteroidCollisionNode: asteroidCollisionNode)
                    break
                }
                asteroidCollisionNode = asteroidCollisionNode?.next
            }
            shipCollisionNode = shipCollisionNode?.next
        }
    }

    func distance(_ from: CGPoint, _ to: CGPoint) -> Double {
        hypot(from.x - to.x, from.y - to.y)
    }

//    func distance(_ from: CGPoint, _ to: CGPoint) -> Double {
//        sqrt((from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y))
//    }

    override public func removeFromEngine(engine: Engine) {
        creator = nil
        appStateNodes = nil
        ships = nil
        asteroids = nil
        bullets = nil
        gunSuppliers = nil
    }
}


