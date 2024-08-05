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
            let entity = Entity()
                    .add(component: alienComponent)
                    .add(component: position)
                    .add(component: velocity)
            engine.add(entity: entity)
            // ACT
            system.pickTarget(entity: entity, alienComponent: alienComponent, position: position, velocity: velocity)
            let result = entity.find(componentClass: MoveToTargetComponent.self)
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
            system.pickTarget(entity: entity, alienComponent: alienComponent, position: position, velocity: velocity)
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
            system.pickTarget(entity: entity, alienComponent: alienComponent, position: position, velocity: velocity)
            let result = entity.find(componentClass: MoveToTargetComponent.self)
            // ASSERT
            XCTAssertNil(result)
        }
    }
}
    
    
