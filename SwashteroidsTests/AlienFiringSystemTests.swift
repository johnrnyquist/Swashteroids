//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

@testable import Swashteroids
@testable import Swash
import XCTest
import Foundation

final class AlienFiringSystemTests: XCTestCase {
    var system: AlienFiringSystem!
    var torpedoCreator: MockTorpedoCreator!

    override func setUp() {
        let gameSize = CGSize(width: 1024.0, height: 768.0)
        torpedoCreator = MockTorpedoCreator()
        system = AlienFiringSystem(torpedoCreator: torpedoCreator, gameSize: gameSize)
    }

    override func tearDown() {
        system = nil
        torpedoCreator = nil
    }

    func test_updateNode() {
        // ARRANGE
        let alienSoldierComponent = AlienSoldierComponent()
        let alienEntity = Entity()
                .add(component: alienSoldierComponent)
        let node = AlienFiringNode()
        node.entity = alienEntity
        let velocityComponent = VelocityComponent(velocityX: 0, velocityY: 0)
        let positionComponent = PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0)
        let gunComponent = GunComponent(offsetX: 0,
                                        offsetY: 0,
                                        minimumShotInterval: 0,
                                        torpedoLifetime: 0,
                                        ownerType: .computerOpponent,
                                        ownerEntity: alienEntity,
                                        numTorpedoes: 0)
        let alienComponent = AlienComponent(cast: .soldier, reactionTime: 0, scoreValue: 0)
        let alienFiringComponent = AlienFiringComponent.shared
        node.components = [
            AlienComponent.name: alienComponent,
            AlienFiringComponent.name: alienFiringComponent,
            GunComponent.name: gunComponent,
            PositionComponent.name: positionComponent,
            VelocityComponent.name: velocityComponent,
        ]
        gunComponent.timeSinceLastShot = gunComponent.minimumShotInterval + 1
        let targetedEntity = Entity()
        alienComponent.targetedEntity = targetedEntity
        targetedEntity
                .add(component: PositionComponent(x: 0, y: 0, z: .asteroids))
                .add(component: ShootableComponent.shared)
        // ACT
        system.updateNode(node: node, time: 1.0)
        // ASSERT
        XCTAssertEqual(torpedoCreator.createTorpedoCalled, 3)
    }

    class MockTorpedoCreator: TorpedoCreatorUseCase {
        var createTorpedoCalled = 0

        func createTorpedo(_ gunComponent: GunComponent, _ position: PositionComponent, _ velocity: VelocityComponent) {
            createTorpedoCalled += 1
        }
    }
}
