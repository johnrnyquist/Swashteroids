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
@testable import Swashteroids
@testable import Swash

final class AlienWorkerSystemTests: XCTestCase {
    var alienEntity: Entity!
    var alienNode: AlienWorkerNode!
    var engine: Engine!
    var position: PositionComponent!
    var system: AlienWorkerSystem!
    var targetableNodes: NodeList!
    var targetedEntity: Entity!
    var velocity: VelocityComponent!

    override func setUpWithError() throws {
        // set up a targetable node
        targetedEntity = Entity(named: "targetableEntity")
        let targetableNode = AlienWorkerTargetNode()
        targetableNode.entity = targetedEntity
        targetableNodes = NodeList()
        targetableNodes.add(node: targetableNode)
        // set up the system
        system = AlienWorkerSystem(randomness: MockRandom())
        system.targetableNodes = targetableNodes
        //
        engine = Engine()
        system.engine = engine
        // Entity
        let alienComponent = AlienComponent(reactionTime: 0.4, killScore: 50)
        alienComponent.targetedEntity = targetedEntity
        let alienWorkerComponent = AlienWorkerComponent()
        position = PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0)
        velocity = VelocityComponent(velocityX: 10, velocityY: 10, scaleManager: MockScaleManager_halfSize())
        alienEntity = Entity()
        alienEntity.add(component: alienComponent)
                   .add(component: position)
                   .add(component: velocity)
                   .add(component: alienWorkerComponent)
                   .add(component: GunComponent(offsetX: 0,
                                                offsetY: 0,
                                                minimumShotInterval: 0,
                                                torpedoLifetime: 0,
                                                ownerType: .computerOpponent,
                                                ownerEntity: alienEntity,
                                                numTorpedoes: 0))
        try! engine.add(entity: alienEntity)
        alienNode = engine.getNodeList(nodeClassType: AlienWorkerNode.self).head as? AlienWorkerNode
    }

    override func tearDownWithError() throws {
        alienEntity = nil
        alienNode = nil
        engine = nil
        position = nil
        system = nil
        targetableNodes = nil
        targetedEntity = nil
        velocity = nil
    }

    func test_updateNode_noPlayer_hasGun() throws {
        // ARRANGE
        // ACT
        system.updateNode(node: alienNode, time: 1)
        // ASSERT
        // Alien has been oriented so it will zip off the screen
        XCTAssertEqual(velocity.x, -15.0) // -15.0
        XCTAssertEqual(velocity.y, 0) // 0.0
        XCTAssertEqual(position.rotationRadians, 3.141592653589793) // 3.141592653589793
    }

    func test_updateNode_hasPlayer_hasGun() throws {
        // ARRANGE
        class AlienWorkerSystem_hasPlayer: AlienWorkerSystem {
            override var playerDead: Bool { false }
        }

        let system = AlienWorkerSystem_hasPlayer(randomness: MockRandom())
        // ACT
        system.updateNode(node: alienNode, time: 1)
        // ASSERT
        // Alien has been oriented so it will zip off the screen
        XCTAssertEqual(velocity.x, 5.0) // -15.0
        XCTAssertEqual(velocity.y, 5.0) // 0.0
        XCTAssertEqual(position.rotationRadians, 0.0) // 3.141592653589793
    }

    func test_updateNode_noPlayer_noGun_atDest_removesAlien() throws {
        // ARRANGE
        alienEntity.remove(componentClass: GunComponent.self)
        // ACT
        system.updateNode(node: alienNode, time: 1)
        // ASSERT
        XCTAssertEqual(velocity.x, 5.0)
        XCTAssertEqual(velocity.y, 5.0)
        XCTAssertEqual(position.rotationRadians, 0.0)
        XCTAssertNil(engine.findEntity(named: alienEntity.name))
    }

    func test_moveTowardTarget() throws {
        let position = PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0)
        let velocity = VelocityComponent(velocityX: 10, velocityY: 10)
        system.moveTowardTarget(position, velocity, CGPoint(x: 100, y: 100))
        XCTAssertEqual(velocity.x, 3.452669830012439)
        XCTAssertEqual(velocity.y, 3.4526698300124394)
        XCTAssertEqual(position.rotationRadians, 0.7853981633974483)
    }
}
