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
//final class AlienSoldierSystemTests: XCTestCase {
//    var shipNodes: NodeList!
//    var shipEntity: Entity!
//    var alienEntity: Entity!
//    var alienNode: AlienSoldierNode!
//
//    override func setUpWithError() throws {
//        shipNodes = NodeList()
//        let shipNode = ShipNode()
//        shipNodes.add(node: shipNode)
//        shipEntity = Entity()
//                .add(component: PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0))
//        shipNode.entity = shipEntity
//        // alienEntity
//        let positionComponent = PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0)
//        let velocityComponent = VelocityComponent(velocityX: 0, velocityY: 0)
//        let alienComponent = AlienComponent(cast: .soldier, reactionTime: 0.4, scoreValue: 50)
//        let alienSoldierComponent = AlienSoldierComponent()
//        alienComponent.targetedEntity = shipEntity
//        alienEntity = Entity()
//                .add(component: alienSoldierComponent)
//                .add(component: alienComponent)
//                .add(component: positionComponent)
//                .add(component: velocityComponent)
//        alienEntity.add(component: GunComponent(offsetX: 0,
//                                                offsetY: 0,
//                                                minimumShotInterval: 0,
//                                                torpedoLifetime: 0,
//                                                ownerType: .computerOpponent,
//                                                ownerEntity: alienEntity,
//                                                numTorpedoes: 0))
//        // alienNode
//        alienNode = AlienSoldierNode()
//        alienNode.entity = alienEntity
//        alienNode.components = [
//            AlienSoldierComponent.name: alienSoldierComponent,
//            AlienComponent.name: alienComponent,
//            PositionComponent.name: positionComponent,
//            VelocityComponent.name: velocityComponent,
//        ]
//    }
//
//    override func tearDownWithError() throws {
//        shipNodes = nil
//        shipEntity = nil
//    }
//
//
//    func test_updateNode_playerDead() throws {
//        let system = Testable_AlienSoldierSystem_playerDead()
//        let alienComponent = alienEntity.find(componentClass: AlienComponent.self)!
//        let positionComponent = alienEntity.find(componentClass: PositionComponent.self)!
//        let velocityComponent = alienEntity.find(componentClass: VelocityComponent.self)!
//        // ACT
//        system.updateNode(node: alienNode, time: 1)
//        // ASSERT
//        XCTAssertEqual(alienComponent.timeSinceLastReaction, 0)
//        XCTAssertFalse(alienEntity.has(componentClass: GunComponent.self))
//        XCTAssertEqual(positionComponent.rotationRadians, CGFloat.pi)
//        XCTAssertEqual(velocityComponent.linearVelocity, .zero)
//    }
//
//    func test_updateNode_targetDead() throws {
//        let system = Testable_AlienSoldierSystem_targetDead()
//        let alienComponent = alienEntity.find(componentClass: AlienComponent.self)!
//        alienComponent.targetedEntity = shipEntity
//        // ACT
//        system.updateNode(node: alienNode, time: 1)
//        // ASSERT
//        XCTAssertEqual(alienComponent.timeSinceLastReaction, 0)
//        XCTAssertNil(alienComponent.targetedEntity)
//    }
//
//    func test_updateNode_playerDead_noGun() throws {
//        let system = Testable_AlienSoldierSystem_playerDead()
//        let soldier = AlienComponent(cast: .soldier, reactionTime: 0.4, scoreValue: 50)
//        let alienComponent = AlienComponent(cast: .soldier, reactionTime: 0.4, scoreValue: 50)
//        let positionComponent = PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0)
//        let velocityComponent = VelocityComponent(velocityX: 0, velocityY: 0)
//        let alienNode = AlienSoldierNode()
//        let alienEntity = Entity()
//        alienNode.entity = alienEntity
//        alienNode.components = [
//            AlienSoldierComponent.name: soldier,
//            AlienComponent.name: alienComponent,
//            PositionComponent.name: positionComponent,
//            VelocityComponent.name: velocityComponent,
//        ]
//        // ACT
//        system.updateNode(node: alienNode, time: 1)
//        // ASSERT
//        XCTAssertEqual(alienComponent.timeSinceLastReaction, 0)
//    }
//
//    func test_updateNode_playerAlive() throws {
//        let system = Testable_AlienSoldierSystem_playerAlive()
//        let alienComponent = alienEntity.find(componentClass: AlienComponent.self)!
//        let velocityComponent = alienEntity.find(componentClass: VelocityComponent.self)!
//        // ACT
//        system.updateNode(node: alienNode, time: 1)
//        // ASSERT
//        XCTAssertEqual(alienComponent.timeSinceLastReaction, 0)
//        XCTAssertEqual(velocityComponent.linearVelocity, .zero)
//        XCTAssertTrue(system.pickTargetCalled)
//        XCTAssertTrue(system.moveTowardsTargetCalled)
//    }
//
//    // MARK: - Testable classes
//    class Testable_AlienSoldierSystem_playerAlive: AlienSoldierSystem {
//        var pickTargetCalled = false
//        var moveTowardsTargetCalled = false
//        var targetedEntity: Entity?
//        override var playerAlive: Bool { true }
//
//        override func pickTarget(alienComponent: AlienComponent, position: PositionComponent) {
//            pickTargetCalled = true
//            targetedEntity = Entity()
//                    .add(component: PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0))
//            alienComponent.targetedEntity = targetedEntity
//        }
//
//        override func moveTowardTarget(_ position: PositionComponent, _ velocity: VelocityComponent, _ target: CGPoint) {
//            moveTowardsTargetCalled = true
//        }
//    }
//
//    class Testable_AlienSoldierSystem_playerDead: AlienSoldierSystem {
//        override var playerAlive: Bool { false }
//    }
//
//    class Testable_AlienSoldierSystem_targetDead: AlienSoldierSystem {
//        override func isTargetDead(_ entity: Entity?) -> Bool { true }
//    }
//}
