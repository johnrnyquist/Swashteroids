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
    private let asteroidCreator: AsteroidCreatorUseCase
    private let randomness: Randomizing
    private let scaleManager: ScaleManaging
    private let shipCreator: ShipCreatorUseCase
    private var size: CGSize
    private weak var aliens: NodeList!
    private weak var appStateNodes: NodeList!
    private weak var asteroids: NodeList!
    private weak var engine: Engine!
    private weak var hyperspacePowerUp: NodeList!
    private weak var shipButtonControlsCreator: ShipButtonControlsCreatorUseCase!
    private weak var ships: NodeList!
    private weak var torpedoPowerUp: NodeList!
    private weak var torpedoes: NodeList!
    private weak var treasures: NodeList!

    init(shipCreator: ShipCreatorUseCase,
         asteroidCreator: AsteroidCreatorUseCase,
         shipButtonControlsCreator: ShipButtonControlsCreatorUseCase,
         size: CGSize,
         randomness: Randomizing = Randomness.shared,
         scaleManager: ScaleManaging = ScaleManager.shared) {
        self.shipCreator = shipCreator
        self.asteroidCreator = asteroidCreator
        self.shipButtonControlsCreator = shipButtonControlsCreator
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

    func shipAndTorpedoPowerUp(shipNode: Node, torpedoPowerUpNode: Node) {
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
        shipButtonControlsCreator.showFireButton()
        //END_HACK
    }

    func shipAndHyperspacePowerUp(shipNode: Node, hyperspace: Node) {
        engine.remove(entity: hyperspace.entity!)
        guard let player = shipNode.entity else { return }
        player
                .add(component: HyperspaceDriveComponent(jumps: 5))
                .add(component: AudioComponent(fileNamed: .powerUp,
                                               actionKey: "powerup.wav"))
        //HACK for immediate gratification
        shipButtonControlsCreator.showHyperspaceButton()
        //END_HACK
    }

    func torpedoesAndAsteroids(torpedoNode: Node, asteroidNode: Node) {
        if let entity = torpedoNode.entity { engine.remove(entity: entity) }
        let level = appStateNodes.head?[AppStateComponent.self]?.level ?? 1
        if let entity = asteroidNode.entity {
            entity.add(component: SplitAsteroidComponent(level: level, splits: 2))
            if let gameStateNode = appStateNodes.head,
               let appStateComponent = gameStateNode[AppStateComponent.self],
               torpedoNode[TorpedoComponent.self]?.owner == .player {
                appStateComponent.score += 25
                appStateComponent.numHits += 1
                appStateComponent.numAsteroidsMined += 1
            }
        }
    }

    func torpedoAndVehicle(torpedoNode: Node, vehicleNode: Node) {
        // Shooter can’t shoot himself
        guard let te = torpedoNode[TorpedoComponent.self]?.ownerEntity,
              let ve = vehicleNode.entity,
              te != ve
        else { return }
        let torpedoOwner = torpedoNode[TorpedoComponent.self]!.owner
        switch torpedoOwner {
        case .player:
            if let _ = ve[ShipComponent.self] { return }
        case .computerOpponent:
            if let _ = ve[AlienComponent.self] { return }
        }
        if let torpedo = torpedoNode.entity { engine.remove(entity: torpedo) }
        if ve[ShipComponent.self] != nil {
            appStateNodes.head?[AppStateComponent.self]?.numShips -= 1
        } else {
            appStateNodes.head?[AppStateComponent.self]?.numAliensDestroyed += 1
        }
        shipCreator.destroy(ship: ve)
        //TODO: refactor the below
        if let gameStateNode = appStateNodes.head,
           let appStateComponent = gameStateNode[AppStateComponent.self],
           torpedoNode[TorpedoComponent.self]?.owner == .player,
           let scoreValue = vehicleNode[AlienComponent.self]?.scoreValue {
            appStateComponent.score += scoreValue
            appStateComponent.numHits += 1
        }
    }

    func vehiclesAndAsteroids(vehicleNode: Node, asteroidNode: Node) {
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
            shipCreator.destroy(ship: vehicleNode.entity!)
        }
        let level = appStateNodes.head?[AppStateComponent.self]?.level ?? 1
        if let entity = asteroidNode.entity {
            entity.add(component: SplitAsteroidComponent(level: level, splits: 2))
        }
    }

    func vehiclesAndTreasures(vehicleNode: Node, treasureNode: Node) {
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

    func shipsAndAliens(shipNode: Node, alienNode: Node) {
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
        shipCreator.destroy(ship: shipEntity)
        shipCreator.destroy(ship: alienEntity)
        if let appState = appStateNodes.head,
           let component = appState[AppStateComponent.self] {
            component.numShips -= 1
        }
    }

    /// 
    /// - Parameter time: The time since the last update
    override public func update(time: TimeInterval) {
        collisionCheck(nodeA: ships.head, nodeB: torpedoPowerUp.head, action: shipAndTorpedoPowerUp)
        collisionCheck(nodeA: ships.head, nodeB: hyperspacePowerUp.head, action: shipAndHyperspacePowerUp)
        collisionCheck(nodeA: torpedoes.head, nodeB: asteroids.head, action: torpedoesAndAsteroids)
        for vehicle in [ships.head, aliens.head] {
            collisionCheck(nodeA: torpedoes.head, nodeB: vehicle, action: torpedoAndVehicle)
            collisionCheck(nodeA: vehicle, nodeB: asteroids.head, action: vehiclesAndAsteroids)
            collisionCheck(nodeA: vehicle, nodeB: treasures.head, action: vehiclesAndTreasures)
        }
        collisionCheck(nodeA: ships.head, nodeB: aliens.head, action: shipsAndAliens)
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


