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

class CollisionSystemTests: XCTestCase {
    var creator: AsteroidCreator!

    override func setUpWithError() throws {
        creator = MockAsteroidCreator()
    }

    override func tearDownWithError() throws {
        creator = nil
    }

    func test_Update() {
        let system = MockCollisionSystem(creator: creator,
                                         size: .zero,
                                         scaleManager: MockScaleManager())
        system.update(time: 1)
        XCTAssertTrue(system.shipTorpedoPowerUpCollisionCheckCalled)
        XCTAssertTrue(system.shipHSCollisionCheckCalled)
        XCTAssertTrue(system.torpedoAsteroidCollisionCheckCalled)
        XCTAssertTrue(system.shipAsteroidCollisionCheckCalled)
        
        class MockCollisionSystem: CollisionSystem {
            var shipTorpedoPowerUpCollisionCheckCalled = false
            var shipHSCollisionCheckCalled = false
            var torpedoAsteroidCollisionCheckCalled = false
            var shipAsteroidCollisionCheckCalled = false

            override func shipTorpedoPowerUpCollisionCheck() {
                shipTorpedoPowerUpCollisionCheckCalled = true
            }

            override func shipHSCollisionCheck() {
                shipHSCollisionCheckCalled = true
            }

            override func torpedoAsteroidCollisionCheck() {
                torpedoAsteroidCollisionCheckCalled = true
            }

            override func shipAsteroidCollisionCheck() {
                shipAsteroidCollisionCheckCalled = true
            }
        }
    }

    class MockAsteroidCreator: AsteroidCreator {
        var createAsteroidCalled = false

        func createAsteroid(radius: Double, x: Double, y: Double, level: Int) {
            createAsteroidCalled = true
        }
    }

    class MockScaleManager: ScaleManaging {
        var SCALE_FACTOR: CGFloat { 1.0 }
    }
}