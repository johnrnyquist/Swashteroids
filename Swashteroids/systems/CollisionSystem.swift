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

enum Damage {
    case light
    case heavy
}

class DamagedComponent: Component {
    var damage: Damage = .light

    init(damage: Damage) {
        self.damage = damage
        super.init()
    }
}

/// This class is an argument for switching to the SpriteKit physics engine.
class CollisionSystem: System {
    private var gameSize: CGSize
    private weak var aliens: NodeList!
    private weak var appStateNodes: NodeList!
    private weak var asteroids: NodeList!
    private weak var creator_asteroids: AsteroidCreatorUseCase!
    private weak var creator_players: PlayerCreatorUseCase!
    private weak var creator_shipButtons: ShipButtonCreatorUseCase!
    private weak var engine: Engine!
    private weak var players: NodeList!
    private weak var powerUps_hyperspace: NodeList!
    private weak var powerUps_shield: NodeList!
    private weak var powerUps_torpedo: NodeList!
    private weak var powerUps_xRay: NodeList!
    private weak var randomness: Randomizing!
    private weak var scaleManager: ScaleManaging!
    private weak var shields: NodeList!
    private weak var torpedoes: NodeList!
    private weak var treasures: NodeList!
    private weak var tunnels: NodeList!

    init(shipCreator: PlayerCreatorUseCase,
         asteroidCreator: AsteroidCreatorUseCase,
         shipButtonControlsCreator: ShipButtonCreatorUseCase,
         gameSize: CGSize,
         randomness: Randomizing = Randomness.shared,
         scaleManager: ScaleManaging = ScaleManager.shared) {
        creator_players = shipCreator
        creator_asteroids = asteroidCreator
        creator_shipButtons = shipButtonControlsCreator
        self.gameSize = gameSize
        self.randomness = randomness
        self.scaleManager = scaleManager
    }

    override public func addToEngine(engine: Engine) {
        self.engine = engine
        aliens = engine.getNodeList(nodeClassType: AlienCollisionNode.self)
        appStateNodes = engine.getNodeList(nodeClassType: SwashteroidsStateNode.self)
        asteroids = engine.getNodeList(nodeClassType: AsteroidCollisionNode.self)
        players = engine.getNodeList(nodeClassType: PlayerCollisionNode.self)
        powerUps_hyperspace = engine.getNodeList(nodeClassType: HyperspacePowerUpNode.self)
        powerUps_shield = engine.getNodeList(nodeClassType: ShieldPowerUpNode.self)
        powerUps_torpedo = engine.getNodeList(nodeClassType: GunPowerUpNode.self)
        powerUps_xRay = engine.getNodeList(nodeClassType: XRayPowerUpNode.self)
        shields = engine.getNodeList(nodeClassType: ShieldNode.self)
        torpedoes = engine.getNodeList(nodeClassType: TorpedoCollisionNode.self)
        treasures = engine.getNodeList(nodeClassType: TreasureCollisionNode.self)
        tunnels = engine.getNodeList(nodeClassType: WarpTunnelNode.self)
    }

    override public func update(time: TimeInterval) {
        collisionCheck(nodeA: players.head, nodeB: powerUps_torpedo.head, action: playerAndTorpedoPowerUp)
        collisionCheck(nodeA: players.head, nodeB: powerUps_hyperspace.head, action: playerAndHyperspacePowerUp)
        collisionCheck(nodeA: players.head, nodeB: powerUps_xRay.head, action: playerAndXRayPowerUp)
        collisionCheck(nodeA: players.head, nodeB: powerUps_shield.head, action: playerAndShieldsPowerUp)
        collisionCheck(nodeA: players.head, nodeB: tunnels.head, action: playerAndTunnel)
        collisionCheck(nodeA: torpedoes.head, nodeB: asteroids.head, action: torpedoesAndAsteroids)
        for vehicle in [players.head, aliens.head] {
            collisionCheck(nodeA: vehicle, nodeB: torpedoes.head, action: vehiclesAndTorpedoes)
            collisionCheck(nodeA: vehicle, nodeB: asteroids.head, action: vehiclesAndAsteroids)
            collisionCheck(nodeA: vehicle, nodeB: treasures.head, action: vehiclesAndTreasures)
        }
        collisionCheck(nodeA: players.head, nodeB: aliens.head, action: playersAndAliens)
        // 
        collisionCheck(nodeA: shields.head, nodeB: aliens.head, action: shieldsAndAliens)
        collisionCheck(nodeA: shields.head, nodeB: asteroids.head, action: shieldsAndAsteroids)
        collisionCheck(nodeA: shields.head, nodeB: torpedoes.head, action: shieldsAndTorpedoes)
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
                let distance = nodeB_position.point.distance(from: nodeA_position.point)
                if (distance <= nodeB_collision.radius + nodeA_collision.radius) {
                    action(currentNodeA, currentNodeB)
                    break
                }
                nodeB = currentNodeB.next
            }
            nodeA = currentNodeA.next
        }
    }

    func playerAndTorpedoPowerUp(shipNode: Node, torpedoPowerUpNode: Node) {
        engine.remove(entity: torpedoPowerUpNode.entity!)
        guard let player = shipNode.entity else { return }
        player.remove(componentClass: FireDownComponent.self) //HACK to prevent having one in the chamber
        player
                .add(component: GunComponent(offsetX: player.sprite!.width / 2,
                                             offsetY: 0,
                                             minimumShotInterval: 0.125,
                                             torpedoLifetime: 2,
                                             torpedoColor: .torpedo,
                                             ownerType: .player,
                                             ownerName: player.name,
                                             numTorpedoes: 20))
                .add(component: AudioComponent(asset: .powerup))
        creator_shipButtons.showFireButton()
    }

    func playerAndHyperspacePowerUp(playerNode: Node, hyperspace: Node) {
        engine.remove(entity: hyperspace.entity!)
        guard let player = playerNode.entity else { return }
        player.remove(componentClass: HyperspaceDriveComponent.self) //HACK to prevent having one in the chamber
        player
                .add(component: HyperspaceDriveComponent(jumps: 5))
                .add(component: AudioComponent(asset: .powerup))
        creator_shipButtons.showHyperspaceButton()
    }

    func playerAndXRayPowerUp(playerNode: Node, xRayPowerUp: Node) {
        engine.remove(entity: xRayPowerUp.entity!)
        guard let player = playerNode.entity else { return }
        player
                .add(component: XRayVisionComponent())
                .add(component: AudioComponent(asset: .powerup))
    }

    func playerAndShieldsPowerUp(playerNode: Node, shieldsPowerUp: Node) {
        engine.remove(entity: shieldsPowerUp.entity!)
        guard let player = playerNode.entity,
              let point = player[PositionComponent.self]?.point,
              let radius = player[CollidableComponent.self]?.radius,
              let playerSprite = player[DisplayComponent.self]?.sprite
        else { return }
        player
                .add(component: AudioComponent(asset: .powerup))
        let spriteNode = AssetImage.shield.swashSprite
        spriteNode.color = .shields
        spriteNode.colorBlendFactor = 1.0
        spriteNode.size = playerSprite.size.width.cgSize * 1.6
        let entity = Entity(named: .shield)
                .add(component: ShieldComponent(maxStrength: 3.0, curStrength: 3.0))
                .add(component: CollidableComponent(radius: radius / scaleManager.SCALE_FACTOR * 1.6)) //undo scaleManager scaling on radius
                .add(component: PositionComponent(x: point.x, y: point.y, z: .player))
                .add(component: DisplayComponent(sknode: spriteNode))
                .add(component: VelocityComponent(velocityX: 0, velocityY: 0, angularVelocity: 15))
        spriteNode.swashEntity = entity
        engine.add(entity: entity)
    }

    func playerAndTunnel(playerNode: Node, bridge: Node) {
        engine.remove(entity: bridge.entity!)
        guard let player = playerNode.entity else { return }
        player
                .add(component: AudioComponent(asset: .level_up))
                .add(component: StartNewGameComponent())
    }

    func torpedoesAndAsteroids(torpedoNode: Node, asteroidNode: Node) {
        if let entity = torpedoNode.entity { engine.remove(entity: entity) }
        let level = appStateNodes.head?[GameStateComponent.self]?.level ?? 1
        if let entity = asteroidNode.entity {
            entity.add(component: SplitAsteroidComponent(level: level, splits: 2))
            if let gameStateNode = appStateNodes.head,
               let appStateComponent = gameStateNode[GameStateComponent.self],
               torpedoNode[TorpedoComponent.self]?.owner == .player {
                appStateComponent.score += 25
                appStateComponent.numHits += 1
                appStateComponent.numAsteroidsMined += 1
            }
        }
    }

    func vehiclesAndTorpedoes(vehicleNode: Node, torpedoNode: Node) {
        guard let torpedoOwner = torpedoNode[TorpedoComponent.self]?.owner,
              let torpedoOwnerName = torpedoNode[TorpedoComponent.self]?.ownerName,
              let torpedoEntity = torpedoNode.entity,
              let vehicleEntity = vehicleNode.entity,
              let torpedoOwnerEntity = engine.findEntity(named: torpedoOwnerName),
              torpedoOwnerEntity != vehicleEntity else { return }
        if isFriendlyFire(torpedoOwner: torpedoOwner, vehicleEntity: vehicleEntity) { return }
        engine.remove(entity: torpedoEntity)
        if vehicleEntity[PlayerComponent.self] != nil {
            appStateNodes.head?[GameStateComponent.self]?.numShips -= 1
            creator_players.destroy(entity: vehicleEntity)
        } else if let alienComponent = vehicleEntity[AlienComponent.self],
                  alienComponent.cast == .soldier {
            alienSoldierHit(alien: vehicleEntity)
        } else {
            appStateNodes.head?[GameStateComponent.self]?.numAliensDestroyed += 1
            creator_players.destroy(entity: vehicleEntity)
        }
        if let gameStateNode = appStateNodes.head,
           let appStateComponent = gameStateNode[GameStateComponent.self],
           torpedoOwner == .player,
           let scoreValue = vehicleEntity[AlienComponent.self]?.scoreValue {
            appStateComponent.score += scoreValue
            appStateComponent.numHits += 1
        }
    }

    func vehiclesAndAsteroids(vehicleNode: Node, asteroidNode: Node) {
        if let asteroidVelocity = asteroidNode[VelocityComponent.self],
           let shipVelocity = vehicleNode[VelocityComponent.self],
           vehicleNode.entity?[ExitScreenComponent.self] == nil {
            shipVelocity.linearVelocity = asteroidVelocity.linearVelocity
            shipVelocity.angularVelocity = asteroidVelocity.angularVelocity
        }
        if let vehicle = vehicleNode.entity {
            // If a vehicle hits an asteroid, it enters its death throes. Removing its ability to move or shoot.
            // A vehicle in its death throes can still hit an asteroid.
            if vehicle.has(componentClassName: DeathThroesComponent.name) == false {
                handleVehicleAsteroidCollision(vehicle: vehicle)
            }
        }
        splitAsteroidIfNeeded(asteroidNode: asteroidNode)
    }

    func vehiclesAndTreasures(vehicleNode: Node, treasureNode: Node) {
        engine.remove(entity: treasureNode.entity!)
        if let _ = vehicleNode[PlayerComponent.self],
           let ship = vehicleNode.entity,
           let appState = appStateNodes.head?[GameStateComponent.self],
           let type = treasureNode[TreasureComponent.self]?.type {
            appState.score += type.value
            switch type {
                case .standard:
                    ship.add(component: AudioComponent(asset: .treasure_standard))
                case .special:
                    ship.add(component: AudioComponent(asset: .treasure_special))
            }
        }
    }

    func playersAndAliens(shipNode: Node, alienNode: Node) {
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
        creator_players.destroy(entity: shipEntity)
        if let alienComponent = alienEntity[AlienComponent.self],
           alienComponent.cast == .soldier {
            alienSoldierHit(alien: alienEntity)
        } else {
            creator_players.destroy(entity: alienEntity)
        }
        if let appState = appStateNodes.head,
           let component = appState[GameStateComponent.self] {
            component.numShips -= 1
        }
    }

    func shieldsAndAliens(shields: Node, aliens: Node) {
        appStateNodes.head?[GameStateComponent.self]?.numAliensDestroyed += 1
        guard let alien = aliens.entity else { return }
        creator_players.destroy(entity: alien)
        updateShield(shields: shields)
    }

    func shieldsAndAsteroids(shields: Node, asteroidNode: Node) {
        updateShield(shields: shields)
        let level = appStateNodes.head?[GameStateComponent.self]?.level ?? 1
        if let entity = asteroidNode.entity,
           let player = players.head?.entity,
           let velocity = player[VelocityComponent.self] {
            velocity.x = -velocity.x
            velocity.y = -velocity.y
            entity.add(component: SplitAsteroidComponent(level: level, splits: 2))
            if let gameStateNode = appStateNodes.head,
               let appStateComponent = gameStateNode[GameStateComponent.self] {
                appStateComponent.score += 25
                appStateComponent.numHits += 1
                appStateComponent.numAsteroidsMined += 1
            }
        }
    }

    func shieldsAndTorpedoes(shields: Node, torpedoes: Node) {
        if torpedoes[TorpedoComponent.self]?.owner == .computerOpponent {
            if let entity = torpedoes.entity { engine.remove(entity: entity) }
            updateShield(shields: shields)
        }
    }

    private func updateShield(shields: Node) {
        guard let shieldComponent = shields.entity?[ShieldComponent.self],
              shieldComponent.curStrength > 0
        else { return }
        shieldComponent.curStrength -= 1
        engine.appStateEntity.add(component: AudioComponent(asset: .shield_hit))
        if shieldComponent.curStrength == 0 {
            engine.remove(entity: shields.entity!)
        }
    }

    private func isFriendlyFire(torpedoOwner: OwnerType, vehicleEntity: Entity) -> Bool {
        switch torpedoOwner {
            case .player:
                return vehicleEntity[PlayerComponent.self] != nil
            case .computerOpponent:
                return vehicleEntity[AlienComponent.self] != nil
        }
    }

    private func alienSoldierHit(alien: Entity) {
        guard let damageComponent = alien[DamagedComponent.self] else {
            applyDamage(to: alien,
                        damage: .light,
                        newSprite: AssetImage.alienSoldierLeftDamaged.swashScaledSprite,
                        pieceSprite: AssetImage.alienSoldierLeftPiece.swashScaledSprite)
            return
        }
        if damageComponent.damage == .light {
            damageComponent.damage = .heavy
            applyDamage(to: alien,
                        damage: .heavy,
                        newSprite: AssetImage.alienSoldierBothDamaged.swashScaledSprite,
                        pieceSprite: AssetImage.alienSoldierRightPiece.swashScaledSprite)
        } else {
            appStateNodes.head?[GameStateComponent.self]?.numAliensDestroyed += 1
            creator_players.destroy(entity: alien)
        }
    }

    func applyDamage(to alien: Entity, damage: Damage, newSprite: SKSpriteNode, pieceSprite: SKSpriteNode) {
        alien.remove(componentClass: DisplayComponent.self)
        alien.add(component: DisplayComponent(sknode: newSprite))
        if let velocityComponent = alien[VelocityComponent.self] {
            velocityComponent.base /= 2.0
        }
        alien.add(component: DamagedComponent(damage: damage))
        let fade = SKAction.fadeOut(withDuration: 3.0)
        let emitter = SKEmitterNode(fileNamed: "shipExplosion.sks")!
        emitter.setScale(0.35)
        pieceSprite.colorBlendFactor = 1.0
        pieceSprite.color = .red
        pieceSprite.addChild(emitter)
        pieceSprite.run(fade)
        let piece = Entity()
                .add(component: PositionComponent(x: alien[PositionComponent.self]!.point.x,
                                                  y: alien[PositionComponent.self]!.point.y,
                                                  z: .asteroids))
                .add(component: createVelocity(speedModifier: 1.0, level: 1))
                .add(component: DisplayComponent(sknode: pieceSprite))
                .add(component: LifetimeComponent(timeRemaining: 2.0))
                .add(component: AudioComponent(asset: .explosion))
        engine.add(entity: piece)
    }

    private func splitAsteroidIfNeeded(asteroidNode: Node) {
        let level = appStateNodes.head?[GameStateComponent.self]?.level ?? 1
        if let entity = asteroidNode.entity {
            entity.add(component: SplitAsteroidComponent(level: level, splits: 2))
        }
    }

    private func handleVehicleAsteroidCollision(vehicle: Entity) {
        if let _ = vehicle[PlayerComponent.self] {
            appStateNodes.head?[GameStateComponent.self]?.numShips -= 1
        }
        if let alienComponent = vehicle[AlienComponent.self],
           alienComponent.cast == .soldier {
            alienSoldierHit(alien: vehicle)
        } else {
            creator_players.destroy(entity: vehicle)
        }
    }

    override public func removeFromEngine(engine: Engine) {
        appStateNodes = nil
        players = nil
        asteroids = nil
        torpedoes = nil
        powerUps_torpedo = nil
        powerUps_hyperspace = nil
    }
}


