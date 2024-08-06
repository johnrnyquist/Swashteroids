//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import XCTest
@testable import Swash
@testable import Swashteroids

class PickTargetSystemTests: XCTestCase {
    var system: PickTargetSystem!
//    var shipNodes : NodeList!
//    var asteroidNodes : NodeList!
    var engine: Engine!
    var player: Entity!

    override func setUp() {
        super.setUp()
        engine = Engine()
        system = PickTargetSystem()
        engine.add(system: system, priority: 0)
        player = Entity(named: "player")
                .add(component: PlayerComponent())
                .add(component: PositionComponent(x: 0, y: 0, z: .player, rotationDegrees: 0))
                .add(component: AlienWorkerTargetComponent.shared)
        engine.add(entity: player)
    }

    override func tearDown() {
        system = nil
        engine = nil
        super.tearDown()
    }

    func test_pickTarget_shipIsClosest() {
        for cast in [AlienCast.soldier, AlienCast.worker] {
            // ARRANGE
            let alienComponent = AlienComponent(cast: cast, scaleManager: ScaleManager.shared)
            let position = PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0)
            let velocity = VelocityComponent(velocityX: 0, velocityY: 0)
            let alien = Entity()
                    .add(component: alienComponent)
                    .add(component: position)
                    .add(component: velocity)
            engine.add(entity: alien)
            // ACT
            system.pickTarget(entity: alien)
            let result = alien.find(componentClass: MoveToTargetComponent.self)
            // ASSERT
            XCTAssertNotNil(result)
            XCTAssertEqual(result?.targetedEntityName, player.name)
        }
    }

    func test_pickTarget_closestAsteroid() {
        for alien in [
            (cast: AlienCast.soldier, targetName: "player", x: 100.0),
            (cast: AlienCast.soldier, targetName: "asteroid", x: 10.0),
            (cast: AlienCast.worker, targetName: "asteroid", x: 100.0)] {
            // ARRANGE
            let alienComponent = AlienComponent(cast: alien.cast, scaleManager: ScaleManager.shared)
            let position = PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0)
            let velocity = VelocityComponent(velocityX: 0, velocityY: 0)
            let entity = Entity()
                    .add(component: alienComponent)
                    .add(component: position)
                    .add(component: velocity)
            engine.add(entity: entity)
            player[PositionComponent.self]?.point = CGPoint(x: 200, y: 0)
            let asteroid = Entity(named: "asteroid")
                    .add(component: AsteroidComponent(size: .large))
                    .add(component: CollidableComponent(radius: 10))
                    .add(component: PositionComponent(x: alien.x, y: 0, z: .asteroids))
                    .add(component: VelocityComponent(velocityX: 0, velocityY: 0))
                    .add(component: AlienWorkerTargetComponent.shared)
            engine.add(entity: asteroid)
            // ACT
            system.pickTarget(entity: entity)
            let result = entity.find(componentClass: MoveToTargetComponent.self)
            // ASSERT
            XCTAssertNotNil(result)
            XCTAssertEqual(result?.targetedEntityName, alien.targetName)
        }
    }

    func test_pickTarget_noEntities() {
        for cast in [AlienCast.soldier, AlienCast.worker] {
            // ARRANGE
            let alienComponent = AlienComponent(cast: cast, scaleManager: ScaleManager.shared)
            let position = PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0)
            let velocity = VelocityComponent(velocityX: 0, velocityY: 0)
            let entity = Entity()
                    .add(component: alienComponent)
                    .add(component: position)
                    .add(component: velocity)
            engine.add(entity: entity)
            engine.remove(entity: player)
            // ACT
            system.pickTarget(entity: entity)
            let result = entity.find(componentClass: MoveToTargetComponent.self)
            // ASSERT
            XCTAssertNil(result)
        }
    }

    // write test to cover the uncovered part of the pickTarget function with excludedEntityNames
    func test_pickTarget_excludedEntityNames() {
        // ARRANGE
        let distanceFar = 100.0
        let distanceMedium = 10.0
        let distanceNear = 1.0
        player[PositionComponent.self]?.x = distanceFar
        // first target - targeted by alien1
        let asteroid1 = Entity(named: "asteroid1")
                .add(component: AsteroidComponent(size: .large))
                .add(component: CollidableComponent(radius: 10))
                .add(component: PositionComponent(x: distanceFar, y: 0, z: .asteroids))
                .add(component: VelocityComponent(velocityX: 0, velocityY: 0))
                .add(component: AlienWorkerTargetComponent.shared)
        engine.add(entity: asteroid1)
        // second target - targeted by alien2
        let asteroid2 = Entity(named: "asteroid2")
                .add(component: AsteroidComponent(size: .large))
                .add(component: CollidableComponent(radius: 10))
                .add(component: PositionComponent(x: distanceNear, y: 0, z: .asteroids))
                .add(component: VelocityComponent(velocityX: 0, velocityY: 0))
                .add(component: AlienWorkerTargetComponent.shared)
        engine.add(entity: asteroid2)
        // third - a possible target
        let asteroid3 = Entity(named: "asteroid3")
                .add(component: AsteroidComponent(size: .large))
                .add(component: CollidableComponent(radius: 10))
                .add(component: PositionComponent(x: distanceMedium, y: 0, z: .asteroids))
                .add(component: VelocityComponent(velocityX: 0, velocityY: 0))
                .add(component: AlienWorkerTargetComponent.shared)
        engine.add(entity: asteroid3)
        // alien1 hunter has a target
        let alien1 = Entity(named: "alien1")
                .add(component: AlienComponent(cast: .worker, scaleManager: ScaleManager.shared))
                .add(component: PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0))
                .add(component: VelocityComponent(velocityX: 0, velocityY: 0))
        alien1.add(component: MoveToTargetComponent(hunterName: alien1.name, targetName: asteroid1.name))
        engine.add(entity: alien1)
        // alien2 hunter that has a target
        let alien2 = Entity(named: "alien2")
                .add(component: AlienComponent(cast: .worker, scaleManager: ScaleManager.shared))
                .add(component: PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0))
                .add(component: VelocityComponent(velocityX: 0, velocityY: 0))
        alien2.add(component: MoveToTargetComponent(hunterName: alien2.name, targetName: asteroid2.name))
        engine.add(entity: alien2)
        // ACT
        // alien1 should get asteroid3 now
        system.pickTarget(entity: alien1)
        // ASSERT
        XCTAssertEqual(alien1[MoveToTargetComponent.self]!.targetedEntityName, asteroid3.name)
    }

    func test_findClosestEntity() {
        for data: (cast: AlienCast, node: Node.Type) in [
            (cast: .soldier, node: AsteroidCollisionNode.self),
            (cast: .worker, node: AlienWorkerTargetNode.self)
        ] {
            // ARRANGE
            let alien = Entity()
                    .add(component: AlienComponent(cast: data.cast, scaleManager: ScaleManager.shared))
                    .add(component: PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0))
                    .add(component: VelocityComponent(velocityX: 0, velocityY: 0))
            engine.add(entity: alien)
            let distanceFar = 10.0
            let distanceNear = 1.0
            player[PositionComponent.self]?.x = distanceFar
            let asteroid1 = Entity(named: "asteroid1")
                    .add(component: AsteroidComponent(size: .large))
                    .add(component: CollidableComponent(radius: 10))
                    .add(component: PositionComponent(x: distanceNear, y: 0, z: .asteroids))
                    .add(component: VelocityComponent(velocityX: 0, velocityY: 0))
                    .add(component: AlienWorkerTargetComponent.shared)
            engine.add(entity: asteroid1)
            // ACT
            let result = system.findClosestEntity(to: PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0).point,
                                                  node: engine.getNodeList(nodeClassType: data.node.self).head)
            // ASSERT
            XCTAssertEqual(result?.name, asteroid1.name)
        }
    }

    func test_pickTarget_workerChoosesPlayer() {
        // ARRANGE
        let alien = Entity()
                .add(component: AlienComponent(cast: .worker, scaleManager: ScaleManager.shared))
                .add(component: PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0))
                .add(component: VelocityComponent(velocityX: 0, velocityY: 0))
        engine.add(entity: alien)
        let distanceNear = 10.0
        player[PositionComponent.self]?.x = distanceNear 
        let asteroid1 = Entity(named: "asteroid1")
                .add(component: AsteroidComponent(size: .large))
                .add(component: CollidableComponent(radius: 10))
                .add(component: PositionComponent(x: distanceNear - 1, y: 0, z: .asteroids))
                .add(component: VelocityComponent(velocityX: 0, velocityY: 0))
                .add(component: AlienWorkerTargetComponent.shared)
        engine.add(entity: asteroid1)
        // ACT
        system.pickTarget(entity: alien)
        // ASSERT
        XCTAssertEqual(alien[MoveToTargetComponent.self]?.targetedEntityName, asteroid1.name)
    }
}
    
    
