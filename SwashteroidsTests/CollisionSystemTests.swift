//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import SpriteKit
import XCTest
@testable import Swashteroids
@testable import Swash

class CollisionSystemTests: XCTestCase {
    var creator: MockAsteroidCreator!

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

    func test_SplitAsteroid() {
        let system = CollisionSystem(creator: creator,
                                     size: .zero,
                                     scaleManager: MockScaleManager())
        let positionComponent = PositionComponent(x: 0, y: 0, z: .asteroids)
        let motionComponent = MotionComponent(velocityX: 0, velocityY: 0, scaleManager: MockScaleManager())
        let collisionComponent = CollisionComponent(radius: LARGE_ASTEROID_RADIUS + 1, scaleManager: MockScaleManager())
        let asteroid = Entity()
                .add(component: AsteroidComponent())
                .add(component: positionComponent)
                .add(component: motionComponent)
                .add(component: collisionComponent)
        let node = Node()
        let sprite = SKNode()
        node.components[DisplayComponent.name] = DisplayComponent(sknode: sprite)
        node.components[CollisionComponent.name] = collisionComponent
        let entity = Entity()
        node.entity = entity
        try? system.splitAsteroid(collisionComponent: collisionComponent,
                                  positionComponent: positionComponent,
                                  asteroidCollisionNode: node,
                                  splits: 2,
                                  level: 1)
        XCTAssertEqual(creator.createAsteroidCalled, 2)
        XCTAssertFalse(entity.has(componentClassName: CollisionComponent.name))
        XCTAssertTrue(entity.has(componentClassName: AudioComponent.name))
        XCTAssertTrue(entity.has(componentClassName: DeathThroesComponent.name))
        XCTAssertNotEqual(entity.sprite, sprite)
    }

    func test_ShipTorpedoPowerUpCollisionCheck() {
        XCTFail("Need to write tests for \(#function)!")
    }

    func test_ShipHSCollisionCheck() {
        XCTFail("Need to write tests for \(#function)!")
    }

    func test_TorpedoAsteroidCollisionCheck() {
        XCTFail("Need to write tests for \(#function)!")
    }

    func test_ShipAsteroidCollisionCheck() {
        XCTFail("Need to write tests for \(#function)!")
    }
    
    class MockAsteroidCreator: AsteroidCreator {
        var createAsteroidCalled = 0

        func createAsteroid(radius: Double, x: Double, y: Double, level: Int) {
            createAsteroidCalled += 1
        }
    }

    class MockScaleManager: ScaleManaging {
        var SCALE_FACTOR: CGFloat { 1.0 }
    }
}