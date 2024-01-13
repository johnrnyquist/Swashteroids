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

class FiringSystemTests: XCTestCase {
    var system: FiringSystem!
    var creator: MockTorpedoCreator!
    var engine: Engine!

    override func setUpWithError() throws {
        creator = MockTorpedoCreator()
        system = FiringSystem(creator: creator)
        engine = Engine()
        engine.add(system: system, priority: 1)
    }

    override func tearDownWithError() throws {
        system = nil
    }

    func test_Fire() {
        let time: TimeInterval = 1.0
        let minimumShotInterval = 0.0 // 1 second
        //
        let motion = VelocityComponent(velocityX: 0, velocityY: 0, base: 60.0)
        let position = PositionComponent(x: 0, y: 0, z: .ship)
        let gun = GunComponent(offsetX: 0,
                               offsetY: 0,
                               minimumShotInterval: minimumShotInterval,
                               torpedoLifetime: 0,
                               torpedoColor: .torpedo,
                               ownerType: .player,
                               numTorpedoes: 20)
        let fireDown = FireDownComponent.shared
        //
        let entity = Entity()
                .add(component: motion)
                .add(component: position)
                .add(component: gun)
                .add(component: fireDown)
        try! engine.add(entity: entity)
        // SUT
        system.update(time: time)
        //
        XCTAssertTrue(creator.fired)
        XCTAssertEqual(gun.timeSinceLastShot, 0.0)
    }

    func xtest_TooSoonToFire() {
        let time: TimeInterval = 0.1
        let minimumShotInterval = 1.0 // 1 second
        //
        let motion = VelocityComponent(velocityX: 0, velocityY: 0, base: 60.0)
        let position = PositionComponent(x: 0, y: 0, z: .ship)
        let gun = GunComponent(offsetX: 0,
                               offsetY: 0,
                               minimumShotInterval: minimumShotInterval,
                               torpedoLifetime: 0,
                               torpedoColor: .torpedo,
                               ownerType: .player,
                               numTorpedoes: 20)
        let fireDown = FireDownComponent.shared
        let initialTimeSinceLastShot = gun.timeSinceLastShot
        //
        let entity = Entity()
                .add(component: motion)
                .add(component: position)
                .add(component: gun)
                .add(component: fireDown)
        try? engine.add(entity: entity)
        //
        system.update(time: time)
        XCTAssertFalse(creator.fired)
        XCTAssertEqual(gun.timeSinceLastShot, time + initialTimeSinceLastShot)
    }

    class MockTorpedoCreator: TorpedoCreator & PowerUpCreator {
        var fired = false
        var createHyperspacePowerUpCalled = false
        var createHyperspacePowerUpRadiusCalled = false
        var createPlasmaTorpedoesPowerUpCalled = false
        var createPlasmaTorpedoesPowerUpRadiusCalled = false

        func createTorpedo(_ gunComponent: GunComponent, _ parentPosition: PositionComponent, _ parentVelocity: VelocityComponent) {
            fired = true
        }

        func createHyperspacePowerUp(level: Int) {
            createHyperspacePowerUpCalled = true
        }

        func createHyperspacePowerUp(level: Int, radius: Double) {
            createHyperspacePowerUpRadiusCalled = true
        }

        func createTorpedoesPowerUp(level: Int) {
            createPlasmaTorpedoesPowerUpCalled = true
        }

        func createTorpedoesPowerUp(level: Int, radius: Double) {
            createPlasmaTorpedoesPowerUpRadiusCalled = true
        }
    }
}
