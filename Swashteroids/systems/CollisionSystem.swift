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
    private weak var creator: (AsteroidCreator & ShipCreator & ShipButtonControlsManager)!
    private weak var appStateNodes: NodeList!
    private weak var ships: NodeList!
    private weak var aliens: NodeList!
    private weak var asteroids: NodeList!
    private weak var torpedoes: NodeList!
    private weak var torpedoPowerUp: NodeList!
    private weak var hyperspacePowerUp: NodeList!
    private weak var treasures: NodeList!
    private weak var engine: Engine!
    private var size: CGSize
    let scaleManager: ScaleManaging

    init(creator: AsteroidCreator & ShipCreator & ShipButtonControlsManager, size: CGSize, scaleManager: ScaleManaging = ScaleManager.shared) {
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
        torpedoPowerUp = engine.getNodeList(nodeClassType: GunPowerUpNode.self)
        hyperspacePowerUp = engine.getNodeList(nodeClassType: HyperspacePowerUpNode.self)
        treasures = engine.getNodeList(nodeClassType: TreasureCollisionNode.self)
    }

    /// 
    /// - Parameter time: The time since the last update
    override public func update(time: TimeInterval) {
        // ships and torpedoPowerUps
        collisionCheck(nodeA: ships.head, nodeB: torpedoPowerUp.head) { shipNode, torpedoPowerUpNode in
            engine.remove(entity: torpedoPowerUpNode.entity!)
            shipNode.entity?
                    .add(component: GunComponent(offsetX: 21,
                                                 offsetY: 0,
                                                 minimumShotInterval: 0.125,
                                                 torpedoLifetime: 2,
                                                 torpedoColor: .torpedo,
                                                 ownerType: .player,
                                                 ammo: 20))
            shipNode.entity?
                    .add(component: AudioComponent(fileNamed: .powerUp,
                                                   actionKey: "powerup.wav"))
            //HACK for immediate gratification
            creator.showFireButton()
            let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
            let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: 0.2)
            let seq = SKAction.sequence([fadeIn, fadeOut])
            let sprite = engine.getEntity(named: .fireButton)?[DisplayComponent.self]?.sprite
            sprite?.run(seq)
            //END_HACK
        }
        // ships and hyperspacePowerUps
        collisionCheck(nodeA: ships.head, nodeB: hyperspacePowerUp.head) { shipNode, hyperspace in
            engine.remove(entity: hyperspace.entity!)
            shipNode.entity?
                    .add(component: HyperspaceDriveComponent(jumps: 5))
            shipNode.entity?
                    .add(component: AudioComponent(fileNamed: .powerUp,
                                                   actionKey: "powerup.wav"))
            //HACK for immediate gratification
            creator.showHyperspaceButton()
            let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
            let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: 0.2)
            let seq = SKAction.sequence([fadeIn, fadeOut])
            let sprite = (engine.getEntity(named: .hyperspaceButton)?[DisplayComponent.name] as? DisplayComponent)?.sprite
            sprite?.run(seq)
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
                }
            }
        }
        //
        for vehicle in [ships.head, aliens.head] {
            // torpedoes and vehicles
            collisionCheck(nodeA: torpedoes.head, nodeB: vehicle) { torpedoNode, vehicleNode in
                if let entity = torpedoNode.entity { engine.remove(entity: entity) }
                if let entity = vehicleNode.entity,
                   entity[DeathThroesComponent.self] == nil {
                    if vehicleNode[ShipComponent.self] != nil {
                        appStateNodes.head?[AppStateComponent.self]?.numShips -= 1
                    }
                    creator.destroy(ship: entity)
                }
                //TODO: refactor the below
                if let gameStateNode = appStateNodes.head,
                   let appStateComponent = gameStateNode[AppStateComponent.self],
                   torpedoNode[TorpedoComponent.self]?.owner == .player,
                   vehicle?[DeathThroesComponent.self] == nil,
                   let killScore = vehicleNode[AlienComponent.self]?.killScore {
                    appStateComponent.score += killScore
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
                if let appState = appStateNodes.head,
                   vehicleNode[ShipComponent.self] != nil,
                   let component = appState[AppStateComponent.self],
                   let value = treasureNode[TreasureComponent.self]?.value {
                    let soundName: SoundFileNames
                    if value == treasure_special_value {
                        soundName = .treasure_special
                    } else {
                        soundName = .treasure_standard
                    }
                    vehicleNode.entity?.add(component: AudioComponent(fileNamed: soundName,
                                                                      actionKey: "treasure"))
                    component.score += value
                }
            }
        }
        // ships and aliens
        collisionCheck(nodeA: ships.head, nodeB: aliens.head) { shipNode, alienNode in
            guard let shipEntity = shipNode.entity,
                  let alienEntity = alienNode.entity,
                  let shipVelocity = shipNode[VelocityComponent.self],
                  let alienCollision = alienNode[CollisionComponent.self],
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

    //HACK this is duplicated in Creator.swift
    func addEmitter(colored color: UIColor, on sknode: SKNode) {
        if let emitter = SKEmitterNode(fileNamed: "fireflies_mod.sks") {
            emitter.setScale(1.0 * scaleManager.SCALE_FACTOR)
            let colorRamp: [UIColor] = [color.lighter(by: 30.0).shiftHue(by: 10.0)]
            let keyTimes: [NSNumber] = [1.0]
            let colorSequence = SKKeyframeSequence(keyframeValues: colorRamp, times: keyTimes)
            emitter.particleColorSequence = colorSequence
            sknode.addChild(emitter)
        }
    }

    private func createTreasure(positionComponent: PositionComponent) {
        let r = Int.random(in: 1...5) == 5
        let standard = (color: UIColor.systemGreen, value: treasure_standard_value)
        let special = (color: UIColor.systemPink, value: treasure_special_value)
        let treasureData = r ? special : standard
        let sprite = SwashSpriteNode(color: treasureData.color, size: CGSize(width: 10, height: 10))
        addEmitter(colored: treasureData.color, on: sprite)
        let treasureEntity = Entity(named: "treasure" + "_\(Int.random(in: 0...10_000))")
                .add(component: TreasureComponent(value: treasureData.value))
                .add(component: PositionComponent(x: positionComponent.x,
                                                  y: positionComponent.y,
                                                  z: .asteroids,
                                                  rotationDegrees: 45))
                .add(component: VelocityComponent(velocityX: 0, velocityY: 0, angularVelocity: 25, wraps: true, base: 0))
                .add(component: CollisionComponent(radius: 10))
                .add(component: DisplayComponent(sknode: sprite))
        sprite.entity = treasureEntity
        engine.replace(entity: treasureEntity)
    }

    func splitAsteroid(asteroidEntity: Entity, splits: Int = 2, level: Int) {
        guard let collisionComponent = asteroidEntity[CollisionComponent.self],
              let positionComponent = asteroidEntity[PositionComponent.self]
        else { return }
        if Int.random(in: 1...3) == 3 {
            createTreasure(positionComponent: positionComponent)
        }
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

    func collisionCheck(nodeA: Node?, nodeB: Node?, action: (Node, Node) -> Void) {
        var nodeA = nodeA // make mutable copy
        while let currentNodeA = nodeA {
            var nodeB = nodeB // make mutable copy
            while let currentNodeB = nodeB {
                guard
                    let nodeB_position = currentNodeB[PositionComponent.self],
                    let nodeA_position = currentNodeA[PositionComponent.self],
                    let nodeB_collision = currentNodeB[CollisionComponent.self],
                    let nodeA_collision = currentNodeA[CollisionComponent.self]
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


