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

protocol AsteroidCreator: AnyObject {
    func createAsteroid(radius: Double, x: Double, y: Double, level: Int)
}

/// This class is an argument for switching to the SpriteKit physics engine.
final class CollisionSystem: System {
    private weak var creator: AsteroidCreator!
    private weak var appStateNodes: NodeList!
    private weak var ships: NodeList!
    private weak var asteroids: NodeList!
    private weak var torpedoes: NodeList!
    private weak var torpedoPowerUp: NodeList!
    private weak var hyperspacePowerUp: NodeList!
    private weak var engine: Engine!
    private var size: CGSize
    let scaleManager: ScaleManaging

    init(_ creator: AsteroidCreator, size: CGSize, scaleManager: ScaleManaging = ScaleManager.shared) {
        self.creator = creator
        self.size = size
        self.scaleManager = scaleManager
    }

    override public func addToEngine(engine: Engine) {
        self.engine = engine
        appStateNodes = engine.getNodeList(nodeClassType: AppStateNode.self)
        ships = engine.getNodeList(nodeClassType: ShipCollisionNode.self)
        asteroids = engine.getNodeList(nodeClassType: AsteroidCollisionNode.self)
        torpedoes = engine.getNodeList(nodeClassType: PlasmaTorpedoCollisionNode.self)
        torpedoPowerUp = engine.getNodeList(nodeClassType: GunSupplierNode.self)
        hyperspacePowerUp = engine.getNodeList(nodeClassType: HyperspacePowerUpNode.self)
    }

    /// 
    /// - Parameter time: The time since the last update
    override public func update(time: TimeInterval) {
        shipTorpedoPowerUpCollisionCheck()
        shipHSCollisionCheck()
        torpedoAsteroidCollisionCheck()
        shipAsteroidCollisionCheck()
    }

    private func splitAsteroid(asteroidCollision: CollisionComponent, asteroidPosition: PositionComponent,
                               asteroidCollisionNode: Node?, splits: Int = 2, level: Int) {
        guard let asteroidCollisionNode else { return }
        if (asteroidCollision.radius > LARGE_ASTEROID_RADIUS * scaleManager.SCALE_FACTOR / 4) {
            for _ in 1...splits {
                creator.createAsteroid(radius: asteroidCollision.radius * 1.0 / scaleManager.SCALE_FACTOR / 2.0,
                                       x: asteroidPosition.x + Double.random(in: -5...5),
                                       y: asteroidPosition.y + Double.random(in: -5...5),
                                       level: level)
            }
        }
        let spriteNode = SKNode()
        if let emitter = SKEmitterNode(fileNamed: "shipExplosion.sks") {
            spriteNode.addChild(emitter)
            asteroidCollisionNode.entity?
                                 .remove(componentClass: DisplayComponent.self)
                                 .remove(componentClass: CollisionComponent.self)
                                 .add(component: AudioComponent(fileNamed: "bangLarge.wav",
                                                                actionKey: asteroidCollisionNode.entity!.name))
                                 .add(component: DisplayComponent(sknode: spriteNode))
                                 .add(component: DeathThroesComponent(countdown: 0.2))
        }
    }

    func shipTorpedoPowerUpCollisionCheck() {
        let shipCollisionNode = ships.head
        var torpedoPowerUpNode = torpedoPowerUp?.head
        while torpedoPowerUpNode != nil {
            guard
                let gunSupplierPosition = torpedoPowerUpNode?[PositionComponent.self],
                let shipPosition = shipCollisionNode?[PositionComponent.self],
                let gunSupplierCollision = torpedoPowerUpNode?[CollisionComponent.self],
                let shipCollision = shipCollisionNode?[CollisionComponent.self]
            else { torpedoPowerUpNode = torpedoPowerUpNode?.next; continue }
            let distanceToShip = gunSupplierPosition.position.distance(from: shipPosition.position)
            if (distanceToShip <= gunSupplierCollision.radius + shipCollision.radius) {
                engine.removeEntity(entity: torpedoPowerUpNode!.entity!)
                torpedoPowerUpNode = torpedoPowerUpNode?.next
                shipCollisionNode?.entity?
                                  .add(component: GunComponent(offsetX: 21, offsetY: 0,
                                                               minimumShotInterval: 0.25,
                                                               torpedoLifetime: 2))
                shipCollisionNode?.entity?
                                  .add(component: AudioComponent(fileNamed: "powerup.wav",
                                                                 actionKey: "powerup.wav"))
                //HACK for immediate gratification
                let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
                let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: 0.2)
                let seq = SKAction.sequence([fadeIn, fadeOut])
                let sprite = (engine.getEntity(named: .fireButton)?[DisplayComponent.name] as? DisplayComponent)?.sprite
                sprite?.run(seq)
                //END_HACK
            }
            torpedoPowerUpNode = torpedoPowerUpNode?.next
        }
    }

    func shipHSCollisionCheck() {
        let shipCollisionNode = ships.head
        var hyperspacePowerUpNode = hyperspacePowerUp?.head
        while hyperspacePowerUpNode != nil {
            guard
                let hyperspacePowerUpPosition = hyperspacePowerUpNode?[PositionComponent.self],
                let shipPosition = shipCollisionNode?[PositionComponent.self],
                let hyperspacePowerUpCollision = hyperspacePowerUpNode?[CollisionComponent.self],
                let shipCollision = shipCollisionNode?[CollisionComponent.self]
            else { hyperspacePowerUpNode = hyperspacePowerUpNode?.next; continue }
            let distanceToShip = hyperspacePowerUpPosition.position.distance(from: shipPosition.position)
            if (distanceToShip <= hyperspacePowerUpCollision.radius + shipCollision.radius) {
                engine.removeEntity(entity: hyperspacePowerUpNode!.entity!)
                hyperspacePowerUpNode = hyperspacePowerUpNode?.next
                shipCollisionNode?.entity?
                                  .add(component: HyperspaceEngineComponent())
                shipCollisionNode?.entity?
                                  .add(component: AudioComponent(fileNamed: "powerup.wav",
                                                                 actionKey: "powerup.wav"))
                //HACK for immediate gratification
                let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
                let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: 0.2)
                let seq = SKAction.sequence([fadeIn, fadeOut])
                let sprite = (engine.getEntity(named: .hyperspaceButton)?[DisplayComponent.name] as? DisplayComponent)?.sprite
                sprite?.run(seq)
                //END_HACK
            }
            hyperspacePowerUpNode = hyperspacePowerUpNode?.next
        }
    }

    func torpedoAsteroidCollisionCheck() {
        var torpedoNode = torpedoes?.head
        var asteroidNode: Node?
        while torpedoNode != nil {
            asteroidNode = asteroids?.head
            while asteroidNode != nil {
                guard
                    let asteroidPosition = asteroidNode?[PositionComponent.self],
                    let torpedoPosition = torpedoNode?[PositionComponent.self],
                    let asteroidCollision = asteroidNode?[CollisionComponent.self]
                else { asteroidNode = asteroidNode?.next; continue } // or return? }
                if (asteroidPosition.position.distance(from: torpedoPosition.position) <= asteroidCollision.radius) {
                    engine.removeEntity(entity: torpedoNode!.entity!)
                    let level = (appStateNodes.head?[AppStateComponent.self] as? AppStateComponent)?.level ?? 1
                    splitAsteroid(asteroidCollision: asteroidCollision,
                                  asteroidPosition: asteroidPosition,
                                  asteroidCollisionNode: asteroidNode, level: level)
                    if let gameStateNode = appStateNodes.head,
                       let appStateComponent = gameStateNode[AppStateComponent.self] {
                        appStateComponent.score += 1
                    }
                    break
                }
                asteroidNode = asteroidNode?.next
            }
            torpedoNode = torpedoNode?.next
        }
    }

    func shipAsteroidCollisionCheck() {
        var shipCollisionNode = ships.head
        while shipCollisionNode != nil {
            var asteroidCollisionNode = asteroids.head
            while asteroidCollisionNode != nil {
                guard
                    let ship = shipCollisionNode?.entity as? ShipEntity,
                    let asteroidPosition = asteroidCollisionNode?[PositionComponent.self],
                    let shipPosition = shipCollisionNode?[PositionComponent.self],
                    let asteroidCollision = asteroidCollisionNode?[CollisionComponent.self],
                    let shipCollision = shipCollisionNode?[CollisionComponent.self]
                else { asteroidCollisionNode = asteroidCollisionNode?.next; continue }
                let distanceToShip = asteroidPosition.position.distance(from: shipPosition.position)
                if (distanceToShip <= asteroidCollision.radius + shipCollision.radius) {
                    if let asteroidMotion = asteroidCollisionNode?[MotionComponent.self],
                       let shipMotion = shipCollisionNode?[MotionComponent.self] {
                        shipMotion.velocity = asteroidMotion.velocity
                        shipMotion.angularVelocity = asteroidMotion.angularVelocity
                    }
                    // If a ship hits an asteroid, it enters its death throes. Removing its ability to move or shoot.
                    // A ship in its death throes can still hit an asteroid. 
                    if ship.has(componentClassName: DeathThroesComponent.name) == false { //HACK not sure I like this check
                        ship.destroy()
                        if let appState = appStateNodes.head,
                           let component = appState[AppStateComponent.self] {
                            component.numShips -= 1
                        }
                    }
                    let level = (appStateNodes.head?[AppStateComponent.self] as? AppStateComponent)?.level ?? 1
                    splitAsteroid(asteroidCollision: asteroidCollision,
                                  asteroidPosition: asteroidPosition,
                                  asteroidCollisionNode: asteroidCollisionNode, level: level)
                    break
                }
                asteroidCollisionNode = asteroidCollisionNode?.next
            }
            shipCollisionNode = shipCollisionNode?.next
        }
    }

    override public func removeFromEngine(engine: Engine) {
        appStateNodes = nil
        ships = nil
        asteroids = nil
        torpedoes = nil
        torpedoPowerUp = nil
        hyperspacePowerUp = nil
    }
}


