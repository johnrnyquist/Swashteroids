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

class DeathThroesSystemTests: XCTestCase {
    var system: DeathThroesSystem!

    override func setUpWithError() throws {
        system = DeathThroesSystem()
    }

    override func tearDownWithError() throws {
        system = nil
    }

    func test_Init() throws {
        XCTAssertTrue(system.nodeClass == DeathThroesNode.self)
        XCTAssertNotNil(system.nodeUpdateFunction)
    }

    func test_InCountdown() throws {
        let death = DeathThroesComponent(countdown: 2.0)
        let node = DeathThroesNode()
        node.components[DeathThroesComponent.name] = death
        if system.nodeUpdateFunction == nil {
            XCTFail("nodeUpdateFunction is nil")
        } else {
            system.nodeUpdateFunction!(node, 1)
        }
        XCTAssertEqual(death.countdown, 1.0)
    }

    func test_FinishedCountdown() throws {
        let engine = Engine()
        let deathThroes = DeathThroesComponent(countdown: 1.0)
        let node = DeathThroesNode()
        node.components[DeathThroesComponent.name] = deathThroes
        let entity = Entity(named: "deathThroesEntity")
                .add(component: deathThroes)
        node.entity = entity
        try? engine.add(entity: entity)
        if system.nodeUpdateFunction == nil {
            XCTFail("nodeUpdateFunction is nil")
        } else {
            system.addToEngine(engine: engine)
            system.nodeUpdateFunction!(node, 2.0)
        }
        XCTAssertEqual(deathThroes.countdown, -1.0)
        XCTAssertNil(engine.getEntity(named: "deathThroesEntity"))
    }
}
