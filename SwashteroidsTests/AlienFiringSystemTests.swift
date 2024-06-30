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
    var engine: Engine!

    override func setUp() {
        let gameSize = CGSize(width: 1024.0, height: 768.0)
        torpedoCreator = MockTorpedoCreator()
        system = AlienFiringSystem(torpedoCreator: torpedoCreator, gameSize: gameSize)
        engine = Engine()
        engine.add(system: system, priority: 0)
    }

    override func tearDown() {
        system = nil
        torpedoCreator = nil
        engine = nil
    }

    func test_updateNode() throws {
        // ARRANGE
        let alienEntity = Entity()
        let targetedEntity = Entity()
                .add(component: PositionComponent(x: 10, y: 0, z: 0))
                .add(component: ShootableComponent.shared)
        let alienComponent = AlienComponent(cast: .soldier, scaleManager: ScaleManager.shared)
        let alienFiringComponent = AlienFiringComponent.shared
        let gunComponent = GunComponent(offsetX: 0,
                                        offsetY: 0,
                                        minimumShotInterval: 0,
                                        torpedoLifetime: 0,
                                        ownerType: .computerOpponent,
                                        ownerName: alienEntity.name,
                                        numTorpedoes: 0)
        let moveToTargetComponent = MoveToTargetComponent(hunterName: alienEntity.name, targetName: targetedEntity.name)
        let positionComponent = PositionComponent(x: 0, y: 0, z: .asteroids, rotationDegrees: 0)
        let velocityComponent = VelocityComponent(velocityX: 0, velocityY: 0)
        alienEntity
                .add(component: alienComponent)
                .add(component: alienFiringComponent)
                .add(component: gunComponent)
                .add(component: moveToTargetComponent)
                .add(component: positionComponent)
                .add(component: velocityComponent)
        gunComponent.timeSinceLastShot = gunComponent.minimumShotInterval + 1
        engine.add(entity: alienEntity)
        engine.add(entity: targetedEntity)
        // ACT
        engine.update(time: 1)
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
