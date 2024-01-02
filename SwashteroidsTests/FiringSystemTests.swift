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
        let motion = VelocityComponent(velocityX: 0, velocityY: 0)
        let position = PositionComponent(x: 0, y: 0, z: .ship)
        let gun = GunComponent(offsetX: 0,
                               offsetY: 0,
                               minimumShotInterval: minimumShotInterval,
                               torpedoLifetime: 0)
        let fireDown = FireDownComponent.shared
        //
        let entity = Entity()
                .add(component: motion)
                .add(component: position)
                .add(component: gun)
                .add(component: fireDown)
        try? engine.add(entity: entity)
        system.update(time: time)
        XCTAssertTrue(creator.fired)
        XCTAssertEqual(system.timeSinceLastShot, 0.0)
    }

    func test_TooSoonToFire() {
        let time: TimeInterval = 0.1
        let initialTimeSinceLastShot = system.timeSinceLastShot
        let minimumShotInterval = 1.0 // 1 second
        //
        let motion = VelocityComponent(velocityX: 0, velocityY: 0)
        let position = PositionComponent(x: 0, y: 0, z: .ship)
        let gun = GunComponent(offsetX: 0,
                               offsetY: 0,
                               minimumShotInterval: minimumShotInterval,
                               torpedoLifetime: 0)
        let fireDown = FireDownComponent.shared
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
        XCTAssertEqual(system.timeSinceLastShot, time + initialTimeSinceLastShot)
    }

    class MockTorpedoCreator: TorpedoCreator {
        var fired = false

        func createPlasmaTorpedo(_ gunComponent: GunComponent, _ parentPosition: PositionComponent, _ parentVelocity: VelocityComponent) {
            fired = true
        }
    }
}
