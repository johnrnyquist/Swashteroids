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

final class ShieldSystemTests: XCTestCase {
    var system: ShieldSystem!
    var engine: Engine!

    override func setUpWithError() throws {
        system = ShieldSystem()
        engine = Engine()
        let player = Entity(named: .player)
                .add(component: PlayerComponent())
                .add(component: PositionComponent(x: 1, y: 1, z: .player, rotationDegrees: 0.0))
        engine.add(entity: player)
        let shield = Entity(named: .shield)
                .add(component: ShieldComponent(maxStrength: 3, curStrength: 3))
                .add(component: PositionComponent(x: 0, y: 0, z: .player, rotationDegrees: 0.0))
                .add(component: DisplayComponent(sknode: SwashScaledSpriteNode(imageNamed: "circle.dotted.circle")))
                .add(component: CollidableComponent(radius: 0.0))
        engine.add(entity: shield)
        engine.add(system: system, priority: 1)
    }

    override func tearDownWithError() throws {
        system = nil
        engine = nil
    }

    func test_Init() throws {
        XCTAssertTrue(system.nodeClass == ShieldNode.self)
        XCTAssertNotNil(system.nodeUpdateFunction)
    }

    func test_UpdateNode_fullStrengthShield() throws {
        for strength in [(max: 3.0, cur: 3.0), (max: 3.0, cur: 2.0)] {
            guard let shield = engine.findEntity(named: .shield),
                  let shieldComponent = shield[ShieldComponent.self],
                  let sprite = shield[DisplayComponent.self]?.sprite,
                  let player = engine.findEntity(named: .player)
            else { 
                XCTFail("Failed to find entities")
                return
            }
            shieldComponent.curStrength = strength.cur
            shieldComponent.maxStrength = strength.max
            engine.update(time: 1)
            XCTAssertEqual(shield[PositionComponent.self]?.point, player[PositionComponent.self]?.point)
            XCTAssertEqual(sprite.alpha, CGFloat(strength.cur / strength.max), accuracy: 0.01)
        }
    }
}
