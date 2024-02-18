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

//HACK global constants for now
let treasure_standard_value = 75
let treasure_special_value = 350

/// This class is an argument for switching to the SpriteKit physics engine.
class CollisionSystem: System {
    private let randomness: Randomness
    private let scaleManager: ScaleManaging
    private var size: CGSize
    private weak var creator: (AsteroidCreator & ShipCreator & ShipButtonControlsManager & TreasureCreator)!
    private weak var appStateNodes: NodeList!
    private weak var ships: NodeList!
    private weak var aliens: NodeList!
    private weak var asteroids: NodeList!
    private weak var torpedoes: NodeList!
    private weak var torpedoPowerUp: NodeList!
    private weak var hyperspacePowerUp: NodeList!
    private weak var treasures: NodeList!
    private weak var engine: Engine!

    init(creator: AsteroidCreator & ShipCreator & ShipButtonControlsManager & TreasureCreator, size: CGSize, randomness: Randomness, scaleManager: ScaleManaging = ScaleManager.shared) {
        self.creator = creator
        self.size = size
        self.randomness = randomness
        self.scaleManager = scaleManager
    }

    override public func addToEngine(engine: Engine) {
        self.engine = engine
        appStateNodes = engine.getNodeList(nodeClassType: AppStateNode.self)
        ships = engine.getNodeList(nodeClassType: ShipCollisionNode.self)
        aliens = engine.getNodeList(nodeClassType: AlienCollisionNode.self)
        asteroids = engine.getNodeList(nodeClassType: AsteroidCollisionNode.self)
        torpedoes = engine.getNodeList(nodeClassType: TorpedoCollisionNode.self)
        torpedoPowerUp = engine.getNodeList(nodeClassType: GunPowerUpNode.self)
        hyperspacePowerUp = engine.getNodeList(nodeClassType: HyperspacePowerUpNode.self)
        treasures = engine.getNodeList(nodeClassType: TreasureCollisionNode.self)
    }

    /// 
    /// - Parameter time: The time since the last update
    override public func update(time: TimeInterval) {
        // ship and torpedoPowerUps
        collisionCheck(nodeA: ships.head, nodeB: torpedoPowerUp.head) { shipNode, torpedoPowerUpNode in
            engine.remove(entity: torpedoPowerUpNode.entity!)
            guard let player = shipNode.entity else { return }
            player
                    .add(component: GunComponent(offsetX: player.sprite!.width / 2,
                                                 offsetY: 0,
                                                 minimumShotInterval: 0.125,
                                                 torpedoLifetime: 2,
                                                 torpedoColor: .torpedo,
                                                 ownerType: .player,
                                                 ownerEntity: player,
                                                 numTorpedoes: 20))
                    .add(component: AudioComponent(fileNamed: .powerUp,
                                                   actionKey: "powerup.wav"))
            
            
            
            //HACK for immediate gratification
            creator.showFireButton()
            //END_HACK
        }
        // ship and hyperspacePowerUps
        collisionCheck(nodeA: ships.head, nodeB: hyperspacePowerUp.head) { shipNode, hyperspace in
            engine.remove(entity: hyperspace.entity!)
            guard let player = shipNode.entity else { return }
            player
                    .add(component: HyperspaceDriveComponent(jumps: 5))
                    .add(component: AudioComponent(fileNamed: .powerUp,
                                                   actionKey: "powerup.wav"))
            //HACK for immediate gratification
            creator.showHyperspaceButton()
            //END_HACK
        }
        // torpedoes and asteroids
        collisionCheck(nodeA: torpedoes.head, nodeB: asteroids.head) { torpedoNode, asteroidNode in
            if let entity = torpedoNode.entity { engine.remove(entity: entity) }
            let level = appStateNodes.head?[AppStateComponent.self]?.level ?? 1
            if let entity = asteroidNode.entity {
                splitAsteroid(asteroidEntity: entity, level: level)
                if let gameStateNode = appStateNodes.head,
                   let appStateComponent = gameStateNode[AppStateComponent.self],
                   torpedoNode[TorpedoComponent.self]?.owner == .player {
                    appStateComponent.score += 25
                    appStateComponent.numHits += 1
                    appStateComponent.numAsteroidsMined += 1
                }
            }
        }
        //
        for vehicle in [ships.head, aliens.head] {
            // torpedoes and vehicles
            collisionCheck(nodeA: torpedoes.head, nodeB: vehicle) { torpedoNode, vehicleNode in
                // Shooter can’t shoot himself
                guard let te = torpedoNode[TorpedoComponent.self]?.ownerEntity,
                      let ve = vehicleNode.entity,
                      te != ve
                else { return }
                let torpedoOwner = torpedoNode[TorpedoComponent.self]!.owner
                switch torpedoOwner {
                    case .player:
                        if let _ = ve[ShipComponent.self] {
                            return
                        }
                        break
                    case .computerOpponent:
                        if let _ = ve[AlienComponent.self] {
                            return
                        }
                        break
                }
                if let torpedo = torpedoNode.entity { engine.remove(entity: torpedo) }
                if ve[ShipComponent.self] != nil {
                    appStateNodes.head?[AppStateComponent.self]?.numShips -= 1
                } else {
                    appStateNodes.head?[AppStateComponent.self]?.numAliensDestroyed += 1
                }
                creator.destroy(ship: ve)
                //TODO: refactor the below
                if let gameStateNode = appStateNodes.head,
                   let appStateComponent = gameStateNode[AppStateComponent.self],
                   torpedoNode[TorpedoComponent.self]?.owner == .player,
                   let killScore = vehicleNode[AlienComponent.self]?.killScore {
                    appStateComponent.score += killScore
                    appStateComponent.numHits += 1
                }
            }
            // vehicles and asteroids
            collisionCheck(nodeA: vehicle, nodeB: asteroids.head) { vehicleNode, asteroidNode in
                if let asteroidVelocity = asteroidNode[VelocityComponent.self],
                   let shipVelocity = vehicleNode[VelocityComponent.self] {
                    shipVelocity.linearVelocity = asteroidVelocity.linearVelocity
                    shipVelocity.angularVelocity = asteroidVelocity.angularVelocity
                }
                // If a ship hits an asteroid, it enters its death throes. Removing its ability to move or shoot.
                // A ship in its death throes can still hit an asteroid. 
                if vehicleNode.entity?
                              .has(componentClassName: DeathThroesComponent.name) == false { //HACK not sure I like this check
                    if vehicleNode.entity?[ShipComponent.self] != nil {
                        appStateNodes.head?[AppStateComponent.self]?.numShips -= 1
                    }
                    creator.destroy(ship: vehicleNode.entity!)
                }
                let level = appStateNodes.head?[AppStateComponent.self]?.level ?? 1
                if let entity = asteroidNode.entity {
                    splitAsteroid(asteroidEntity: entity, level: level)
                }
            }
            // vehicles and treasures
            collisionCheck(nodeA: vehicle, nodeB: treasures.head) { vehicleNode, treasureNode in
                engine.remove(entity: treasureNode.entity!)
                if
                    let _ = vehicleNode[ShipComponent.self], // it’s the player
                    let ship = vehicleNode.entity,
                    let appState = appStateNodes.head?[AppStateComponent.self],
                    let value = treasureNode[TreasureComponent.self]?.value {
                    appState.score += value
                    if value == treasure_special_value {
                        ship.add(component: AudioComponent(fileNamed: .treasureSpecial, actionKey: "treasure"))
                    } else {
                        ship.add(component: AudioComponent(fileNamed: .treasureStandard, actionKey: "treasure"))
                    }
                }
            }
        }
        // ships and aliens
        collisionCheck(nodeA: ships.head, nodeB: aliens.head) { shipNode, alienNode in
            guard let shipEntity = shipNode.entity,
                  let alienEntity = alienNode.entity,
                  let shipVelocity = shipNode[VelocityComponent.self],
                  let _ = alienNode[CollidableComponent.self],
                  let alienVelocity = alienNode[VelocityComponent.self]
            else { return }
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
        guard let collisionComponent = asteroidEntity[CollidableComponent.self],
              let positionComponent = asteroidEntity[PositionComponent.self]
        else { return }
        if randomness.nextInt(from: 1, through: 3) == 3 {
            creator.createTreasure(positionComponent: positionComponent)
        }
        if (collisionComponent.radius > LARGE_ASTEROID_RADIUS * scaleManager.SCALE_FACTOR / 4) {
            for _ in 1...splits {
                creator.createAsteroid(radius: collisionComponent.radius * 1.0 / scaleManager.SCALE_FACTOR / 2.0,
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

    func collisionCheck(nodeA: Node?, nodeB: Node?, action: (Node, Node) -> Void) {
        var nodeA = nodeA // make mutable copy
        while let currentNodeA = nodeA {
            var nodeB = nodeB // make mutable copy
            while let currentNodeB = nodeB {
                guard
                    let nodeB_position = currentNodeB[PositionComponent.self],
                    let nodeA_position = currentNodeA[PositionComponent.self],
                    let nodeB_collision = currentNodeB[CollidableComponent.self],
                    let nodeA_collision = currentNodeA[CollidableComponent.self]
                else { nodeB = currentNodeB.next; continue }
                let distance = nodeB_position.position.distance(from: nodeA_position.position)
                if (distance <= nodeB_collision.radius + nodeA_collision.radius) {
                    action(currentNodeA, currentNodeB)
                    break
                }
                nodeB = currentNodeB.next
            }
            nodeA = currentNodeA.next
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


