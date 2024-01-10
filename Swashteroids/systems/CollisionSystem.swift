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

/// This class is an argument for switching to the SpriteKit physics engine.
class CollisionSystem: System {
    private weak var creator: (AsteroidCreator & ShipCreator)!
    private weak var appStateNodes: NodeList!
    private weak var ships: NodeList!
    private weak var aliens: NodeList!
    private weak var asteroids: NodeList!
    private weak var torpedoes: NodeList!
    private weak var torpedoPowerUp: NodeList!
    private weak var hyperspacePowerUp: NodeList!
    private weak var engine: Engine!
    private var size: CGSize
    let scaleManager: ScaleManaging

    init(creator: AsteroidCreator & ShipCreator, size: CGSize, scaleManager: ScaleManaging = ScaleManager.shared) {
        self.creator = creator
        self.size = size
        self.scaleManager = scaleManager
    }

    override public func addToEngine(engine: Engine) {
        self.engine = engine
        appStateNodes = engine.getNodeList(nodeClassType: AppStateNode.self)
        ships = engine.getNodeList(nodeClassType: ShipCollisionNode.self)
        aliens = engine.getNodeList(nodeClassType: AlienCollisionNode.self)
        asteroids = engine.getNodeList(nodeClassType: AsteroidCollisionNode.self)
        torpedoes = engine.getNodeList(nodeClassType: TorpedoCollisionNode.self)
        torpedoPowerUp = engine.getNodeList(nodeClassType: GunSupplierNode.self)
        hyperspacePowerUp = engine.getNodeList(nodeClassType: HyperspacePowerUpNode.self)
    }

    /// 
    /// - Parameter time: The time since the last update
    override public func update(time: TimeInterval) {
        shipTorpedoPowerUpCollisionCheck(shipCollisionNode: ships.head, torpedoPowerUpNode: torpedoPowerUp.head)
        shipHyperspacePowerUpCollisionCheck(shipCollisionNode: ships.head, hyperspacePowerUpNode: hyperspacePowerUp.head)
        torpedoAsteroidCollisionCheck(torpedoCollisionNode: torpedoes.head, asteroidCollisionNode: asteroids.head)
        for vehicle in [ships.head, aliens.head] {
            torpedoVehicleCollisionCheck(torpedoCollisionNode: torpedoes.head, vehicleCollisionNode: vehicle)
            vehicleAsteroidCollisionCheck(node: vehicle, asteroidCollisionNode: asteroids.head)
        }
        shipShipCollisionCheck(ships.head, aliens.head)
    }

    /// Assuming at most one of each... for now.
    func shipShipCollisionCheck(_ ship: Node?, _ alien: Node?) {
        guard let ship,
              let alien
        else { return }
        guard let shipPosition = ship[PositionComponent.self],
              let shipCollision = ship[CollisionComponent.self],
              let shipVelocity = ship[VelocityComponent.self],
              let alienPosition = alien[PositionComponent.self],
              let alienCollision = alien[CollisionComponent.self],
              let alienVelocity = alien[VelocityComponent.self],
              let shipEntity = ship.entity,
              let alienEntity = alien.entity
        else { return }
        if alienPosition.position.distance(from: shipPosition.position) < shipCollision.radius + alienCollision.radius {
            shipEntity.remove(componentClass: VelocityComponent.self)
            alienEntity.remove(componentClass: VelocityComponent.self)
            shipEntity.add(component: alienVelocity)
            alienEntity.add(component: shipVelocity)
            creator.destroy(ship: shipEntity)
            creator.destroy(ship: alienEntity)
            if let appState = appStateNodes.head,
               let component = appState[AppStateComponent.self] {
                component.numShips -= 1
            }
        }
    }

    func splitAsteroid(asteroidEntity: Entity, splits: Int = 2, level: Int) {
        guard let collisionComponent = asteroidEntity[CollisionComponent.self],
              let positionComponent = asteroidEntity[PositionComponent.self]
        else { return }
        if (collisionComponent.radius > LARGE_ASTEROID_RADIUS * scaleManager.SCALE_FACTOR / 4) {
            for _ in 1...splits {
                creator.createAsteroid(radius: collisionComponent.radius * 1.0 / scaleManager.SCALE_FACTOR / 2.0,
                                       x: positionComponent.x + Double.random(in: -5...5),
                                       y: positionComponent.y + Double.random(in: -5...5),
                                       level: level)
            }
        }
        if let emitter = SKEmitterNode(fileNamed: "shipExplosion.sks") {
            let spriteNode = SKNode()
            spriteNode.addChild(emitter)
            asteroidEntity
                    .remove(componentClass: DisplayComponent.self)
                    .remove(componentClass: CollisionComponent.self)
                    .add(component: AudioComponent(fileNamed: .explosion,
                                                   actionKey: asteroidEntity.name))
                    .add(component: DisplayComponent(sknode: spriteNode))
                    .add(component: DeathThroesComponent(countdown: 0.2))
        }
    }

    func shipTorpedoPowerUpCollisionCheck(shipCollisionNode: Node?, torpedoPowerUpNode: Node?) {
        var torpedoPowerUpNode = torpedoPowerUpNode // make mutable copy
        while let currentPowerUp = torpedoPowerUpNode {
            guard
                let gunSupplierPosition = currentPowerUp[PositionComponent.self],
                let shipPosition = shipCollisionNode?[PositionComponent.self],
                let gunSupplierCollision = currentPowerUp[CollisionComponent.self],
                let shipCollision = shipCollisionNode?[CollisionComponent.self]
            else { torpedoPowerUpNode = currentPowerUp.next; continue }
            let distanceToShip = gunSupplierPosition.position.distance(from: shipPosition.position)
            if (distanceToShip <= gunSupplierCollision.radius + shipCollision.radius) {
                engine.remove(entity: currentPowerUp.entity!)
                torpedoPowerUpNode = currentPowerUp.next
                shipCollisionNode?.entity?
                                  .add(component: GunComponent(offsetX: 21, offsetY: 0,
                                                               minimumShotInterval: 0.25,
                                                               torpedoLifetime: 2))
                shipCollisionNode?.entity?
                                  .add(component: AudioComponent(fileNamed: .powerUp,
                                                                 actionKey: "powerup.wav"))
                //HACK for immediate gratification
                let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
                let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: 0.2)
                let seq = SKAction.sequence([fadeIn, fadeOut])
                let sprite = (engine.getEntity(named: .fireButton)?[DisplayComponent.name] as? DisplayComponent)?.sprite
                sprite?.run(seq)
                //END_HACK
            }
            torpedoPowerUpNode = currentPowerUp.next
        }
    }

    func shipHyperspacePowerUpCollisionCheck(shipCollisionNode: Node?, hyperspacePowerUpNode: Node?) {
        var hyperspacePowerUpNode = hyperspacePowerUpNode
        while let currentPowerUp = hyperspacePowerUpNode {
            guard
                let hyperspacePowerUpPosition = currentPowerUp[PositionComponent.self],
                let shipPosition = shipCollisionNode?[PositionComponent.self],
                let hyperspacePowerUpCollision = currentPowerUp[CollisionComponent.self],
                let shipCollision = shipCollisionNode?[CollisionComponent.self]
            else { hyperspacePowerUpNode = currentPowerUp.next; continue }
            let distanceToShip = hyperspacePowerUpPosition.position.distance(from: shipPosition.position)
            if (distanceToShip <= hyperspacePowerUpCollision.radius + shipCollision.radius) {
                engine.remove(entity: currentPowerUp.entity!)
                hyperspacePowerUpNode = currentPowerUp.next
                shipCollisionNode?.entity?
                                  .add(component: HyperspaceEngineComponent())
                shipCollisionNode?.entity?
                                  .add(component: AudioComponent(fileNamed: .powerUp,
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

    func torpedoAsteroidCollisionCheck(torpedoCollisionNode: Node?, asteroidCollisionNode: Node?) {
        var torpedoNode = torpedoCollisionNode
        while let torpedo = torpedoNode {
            var asteroidNode = asteroidCollisionNode
            while let currentAsteroid = asteroidNode {
                guard
                    let asteroidPosition = currentAsteroid[PositionComponent.self],
                    let torpedoPosition = torpedo[PositionComponent.self],
                    let asteroidCollision = currentAsteroid[CollisionComponent.self]
                else { asteroidNode = currentAsteroid.next; continue } // or return? }
                if (asteroidPosition.position.distance(from: torpedoPosition.position) <= asteroidCollision.radius) {
                    if let entity = torpedo.entity { engine.remove(entity: entity) }
                    let level = appStateNodes.head?[AppStateComponent.self]?.level ?? 1
                    if let entity = asteroidNode?.entity {
                        splitAsteroid(asteroidEntity: entity, level: level)
                    }
                    //TODO: refactor the below
                    if let gameStateNode = appStateNodes.head,
                       let appStateComponent = gameStateNode[AppStateComponent.self],
                       torpedo[TorpedoComponent.self]?.owner == .player {
                        appStateComponent.score += 100
                    }
                    break
                }
                asteroidNode = currentAsteroid.next
            }
            torpedoNode = torpedo.next
        }
    }

    func torpedoVehicleCollisionCheck(torpedoCollisionNode: Node?, vehicleCollisionNode: Node?) {
        var torpedoCollisionNode = torpedoCollisionNode
        while let currentTorpedo = torpedoCollisionNode {
            var vehicle = vehicleCollisionNode
            while let currentVehicle = vehicle {
                guard
                    let currentVehiclePosition = currentVehicle[PositionComponent.self],
                    let torpedoPosition = currentTorpedo[PositionComponent.self],
                    let currentVehicleCollision = currentVehicle[CollisionComponent.self],
                    let owner = currentTorpedo[TorpedoComponent.self]?.owner,
                    owner == .player && currentVehicle[AlienComponent.self] != nil ||
                    owner == .computerOpponent && currentVehicle[ShipComponent.self] != nil
                else { vehicle = currentVehicle.next; continue } // or return? }
                if (currentVehiclePosition.position.distance(from: torpedoPosition.position) <= currentVehicleCollision.radius) {
                    if let entity = currentTorpedo.entity { engine.remove(entity: entity) }
                    if let entity = vehicle?.entity,
                       entity[DeathThroesComponent.self] == nil {
                        if vehicle?[ShipComponent.self] != nil {
                            appStateNodes.head?[AppStateComponent.self]?.numShips -= 1
                        }
                        creator.destroy(ship: entity)
                    }
                    //TODO: refactor the below
                    if let gameStateNode = appStateNodes.head,
                       let appStateComponent = gameStateNode[AppStateComponent.self],
                       currentTorpedo[TorpedoComponent.self]?.owner == .player {
                        appStateComponent.score += 500
                    }
                    break
                }
                vehicle = currentVehicle.next
            }
            torpedoCollisionNode = currentTorpedo.next
        }
    }

    func vehicleAsteroidCollisionCheck(node: Node?, asteroidCollisionNode: Node?) {
        var collisionNode = node
        while let currentNode = collisionNode {
            var asteroidCollisionNode = asteroidCollisionNode
            while let currentAsteroid = asteroidCollisionNode {
                guard
                    let ship = currentNode.entity,
                    let asteroidPosition = currentAsteroid[PositionComponent.self],
                    let shipPosition = currentNode[PositionComponent.self],
                    let asteroidCollision = currentAsteroid[CollisionComponent.self],
                    let shipCollision = currentNode[CollisionComponent.self]
                else { asteroidCollisionNode = currentAsteroid.next; continue }
                let distanceToShip = asteroidPosition.position.distance(from: shipPosition.position)
                if (distanceToShip <= asteroidCollision.radius + shipCollision.radius) {
                    if let asteroidVelocity = currentAsteroid[VelocityComponent.self],
                       let shipVelocity = currentNode[VelocityComponent.self] {
                        shipVelocity.linearVelocity = asteroidVelocity.linearVelocity
                        shipVelocity.angularVelocity = asteroidVelocity.angularVelocity
                    }
                    // If a ship hits an asteroid, it enters its death throes. Removing its ability to move or shoot.
                    // A ship in its death throes can still hit an asteroid. 
                    if ship.has(componentClassName: DeathThroesComponent.name) == false { //HACK not sure I like this check
                        if ship[ShipComponent.self] != nil {
                            appStateNodes.head?[AppStateComponent.self]?.numShips -= 1
                        }
                        creator.destroy(ship: ship)
                    }
                    let level = appStateNodes.head?[AppStateComponent.self]?.level ?? 1
                    if let entity = currentAsteroid.entity {
                        splitAsteroid(asteroidEntity: entity, level: level)
                    }
                    break
                }
                asteroidCollisionNode = currentAsteroid.next
            }
            collisionNode = currentNode.next
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


