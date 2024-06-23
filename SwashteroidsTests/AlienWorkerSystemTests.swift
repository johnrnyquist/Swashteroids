////
//// https://github.com/johnrnyquist/Swashteroids
////
//// Download Swashteroids from the App Store:
//// https://apps.apple.com/us/app/swashteroids/id6472061502
////
//// Made with Swash, give it a try!
//// https://github.com/johnrnyquist/Swash
////
//
//import XCTest
//@testable import Swashteroids
//@testable import Swash
//
//final class AlienWorkerSystemTests: XCTestCase {
//    var alienEntity: Entity!
//    var alienWorkerNode: AlienWorkerNode!
//    var engine: Engine!
//    var position: PositionComponent!
//    var system: AlienWorkerSystem!
//    var targetableNodes: NodeList!
//    var targetedEntity: Entity!
//    var velocity: VelocityComponent!
//
//    override func setUpWithError() throws {
//        // set up a targetable node
//        targetedEntity = Entity(named: "targetableEntity")
//        let targetableNode = AlienWorkerTargetNode()
//        targetableNode.entity = targetedEntity
//        targetableNodes = NodeList()
//        targetableNodes.add(node: targetableNode)
//        // set up the system
//        system = AlienWorkerSystem(randomness: MockRandom())
//        system.targetableNodes = targetableNodes
//        //
//        engine = Engine()
//        system.engine = engine
//        // Entity
//        let alienComponent = AlienComponent(cast: .worker, reactionTime: 0.4, scoreValue: 50)
//        alienComponent.targetedEntity = targetedEntity
//        let alienWorkerComponent = AlienWorkerComponent()
//        position = PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0)
//        velocity = VelocityComponent(velocityX: 10, velocityY: 10, scaleManager: MockScaleManager_halfSize())
//        alienEntity = Entity()
//        alienEntity.add(component: alienComponent)
//                   .add(component: position)
//                   .add(component: velocity)
//                   .add(component: alienWorkerComponent)
//                   .add(component: GunComponent(offsetX: 0,
//                                                offsetY: 0,
//                                                minimumShotInterval: 0,
//                                                torpedoLifetime: 0,
//                                                ownerType: .computerOpponent,
//                                                ownerEntity: alienEntity,
//                                                numTorpedoes: 0))
//        try! engine.add(entity: alienEntity)
//        alienWorkerNode = engine.getNodeList(nodeClassType: AlienWorkerNode.self).head as? AlienWorkerNode
//    }
//
//    override func tearDownWithError() throws {
//        alienEntity = nil
//        alienWorkerNode = nil
//        engine = nil
//        position = nil
//        system = nil
//        targetableNodes = nil
//        targetedEntity = nil
//        velocity = nil
//    }
//
//    class Testable_AlienWorkerSystem_update: AlienWorkerSystem {
//        var updateNodeCalled = 0
//
//        override func updateNode(node alienNode: Node, time: TimeInterval) {
//            updateNodeCalled += 1
//        }
//    }
//
//    func test_update_oneAlien() {
//        let system = Testable_AlienWorkerSystem_update()
//        let nodes = NodeList()
//        nodes.add(node: alienWorkerNode)
//        system.alienWorkerNodes = nodes
//        system.update(time: 1)
//        XCTAssertEqual(system.updateNodeCalled, 1)
//    }
//
//    func test_update_noAlien() {
//        let system = Testable_AlienWorkerSystem_update()
//        system.update(time: 1)
//        XCTAssertEqual(system.updateNodeCalled, 0)
//    }
//
//    func test_updateNode_noPlayer_hasGun() throws {
//        // ARRANGE
//        // ACT
//        system.updateNode(node: alienWorkerNode, time: 1)
//        // ASSERT
//        // Alien has been oriented so it will zip off the screen
//        XCTAssertEqual(velocity.x, -15.0) // -15.0
//        XCTAssertEqual(velocity.y, 0) // 0.0
//        XCTAssertEqual(position.rotationRadians, 3.141592653589793) // 3.141592653589793
//    }
//
//    func test_updateNode_hasPlayer_hasGun() throws {
//        // ARRANGE
//        class AlienWorkerSystem_hasPlayer: AlienWorkerSystem {
//            override var playerDead: Bool { false }
//        }
//
//        let system = AlienWorkerSystem_hasPlayer(randomness: MockRandom())
//        // ACT
//        system.updateNode(node: alienWorkerNode, time: 1)
//        // ASSERT
//        // Alien has been oriented so it will zip off the screen
//        XCTAssertEqual(velocity.x, 5.0) // -15.0
//        XCTAssertEqual(velocity.y, 5.0) // 0.0
//        XCTAssertEqual(position.rotationRadians, 0.0) // 3.141592653589793
//    }
//
//    func test_updateNode_noPlayer_noGun_atDest_removesAlien() throws {
//        // ARRANGE
//        alienEntity.remove(componentClass: GunComponent.self)
//        // ACT
//        system.updateNode(node: alienWorkerNode, time: 1)
//        // ASSERT
//        XCTAssertEqual(velocity.x, 5.0)
//        XCTAssertEqual(velocity.y, 5.0)
//        XCTAssertEqual(position.rotationRadians, 0.0)
//        XCTAssertNil(engine.findEntity(named: alienEntity.name))
//    }
//
//    func test_moveTowardTarget() throws {
//        let position = PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0)
//        let velocity = VelocityComponent(velocityX: 10, velocityY: 10)
//        system.moveTowardTarget(position, velocity, CGPoint(x: 100, y: 100))
//        XCTAssertEqual(velocity.x, 3.452669830012439)
//        XCTAssertEqual(velocity.y, 3.4526698300124394)
//        XCTAssertEqual(position.rotationRadians, 0.7853981633974483)
//    }
//
//    func test_handleTargeting() {
//        // ARRANGE
//        class Testable_AlienWorkerSystem_handleTargeting: AlienWorkerSystem {
//            var moveTowardTargetCalled = 0
//            var closestEntity = Entity()
//
//            override func moveTowardTarget(_ position: PositionComponent, _ velocity: VelocityComponent, _ target: CGPoint) {
//                moveTowardTargetCalled += 1
//            }
//
//            override func findClosestEntity(to position: CGPoint, node: Node?) -> Entity? {
//                closestEntity.add(component: PositionComponent(x: 0, y: 0, z: 0))
//            }
//        }
//
//        let system = Testable_AlienWorkerSystem_handleTargeting()
//        let alienComponent = alienEntity.find(componentClass: AlienComponent.self)!
//        let alienPostion = alienEntity.find(componentClass: PositionComponent.self)!
//        let velocityComponent = alienEntity.find(componentClass: VelocityComponent.self)!
//        // ACT
//        system.handleTargeting(alienComponent: alienComponent, alienPosition: alienPostion, velocity: velocityComponent)
//        // ASSERT
//        XCTAssertEqual(alienComponent.targetedEntity, system.closestEntity)
//        XCTAssertEqual(system.moveTowardTargetCalled, 1)
//    }
//}
