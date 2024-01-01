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
import SpriteKit
@testable import Swashteroids
@testable import Swash

final class ShipControlsSystemTests: XCTestCase {
    var creator: MockCreator!
    var engine: Engine!

    override func setUpWithError() throws {
        creator = MockCreator()
        engine = Engine()
    }

    override func tearDownWithError() throws {
        creator = nil
        engine = nil
    }

    func test_Init() throws {
        let system = ShipControlsSystem(creator: creator)
        XCTAssertTrue(system.nodeClass == ShipControlsStateNode.self)
        XCTAssertNotNil(system.nodeUpdateFunction)
    }

    func test_UpdateNode() {
        let system = MockShipControlsSystem_DoToggleButtons(creator: creator)
        let node = ShipControlsStateNode()
        let change = ChangeShipControlsStateComponent(to: .hidingButtons)
        node.components[ChangeShipControlsStateComponent.name] = change
        let entity = Entity()
                .add(component: change)
        node.entity = entity
        system.updateNode(node: node, time: 1.0)
        XCTAssertFalse(entity.has(componentClassName: ChangeShipControlsStateComponent.name))
        XCTAssertTrue(system.do_toggleButtonsCalled)

        class MockShipControlsSystem_DoToggleButtons: ShipControlsSystem {
            var do_toggleButtonsCalled = false

            override func do_toggleButtons(_ to: ShipControlsState) {
                do_toggleButtonsCalled = true
            }
        }
    }

    func test_DoToggleButtons_ToShowingButtons_NoGunNoHyperspace() {
        let system = ShipControlsSystem(creator: creator)
        engine.addSystem(system: system, priority: 1)
        let appStateComponent = AppStateComponent(size: .zero,
                                                  ships: 0,
                                                  level: 0,
                                                  score: 0,
                                                  appState: .playing,
                                                  shipControlsState: .hidingButtons)
        //TODO: do_toggleButtons requires the ShipEntity type as it uses engine.ship. 
        let ship = ShipEntity(name: .ship, state: appStateComponent, size: .zero)
                .add(component: AccelerometerComponent())
        try? engine.addEntity(entity: ship)
        //                
        system.do_toggleButtons(.showingButtons)
        XCTAssertTrue(creator.removeShipControlQuadrantsCalled)
        XCTAssertTrue(creator.createShipControlButtonsCalled)
        XCTAssertTrue(creator.enableShipControlButtonsCalled)
        XCTAssertTrue(creator.removeToggleButtonCalled)
        XCTAssertTrue(creator.createToggleButtonCalled)
        XCTAssertFalse(ship.has(componentClassName: AccelerometerComponent.name))
    }

    func test_DoToggleButtons_ToShowingButtons_HasGun() {
        let system = ShipControlsSystem(creator: creator)
        engine.addSystem(system: system, priority: 1)
        let appStateComponent = AppStateComponent(size: .zero,
                                                  ships: 0,
                                                  level: 0,
                                                  score: 0,
                                                  appState: .playing,
                                                  shipControlsState: .showingButtons)
        //TODO: do_toggleButtons requires the ShipEntity type as it uses engine.ship. 
        let ship = ShipEntity(name: .ship, state: appStateComponent, size: .zero)
                .add(component: AccelerometerComponent())
                .add(component: GunComponent(offsetX: 0, offsetY: 0, minimumShotInterval: 0, torpedoLifetime: 0))
        try? engine.addEntity(entity: ship)
        let fireButton = Entity(name: .fireButton)
                .add(component: DisplayComponent(sknode: SwashSpriteNode()))
        try? engine.addEntity(entity: fireButton)
        //                
        system.do_toggleButtons(.showingButtons)
        XCTAssertTrue(creator.removeShipControlQuadrantsCalled)
        XCTAssertTrue(creator.createShipControlButtonsCalled)
        XCTAssertTrue(creator.enableShipControlButtonsCalled)
        XCTAssertTrue(creator.removeToggleButtonCalled)
        XCTAssertTrue(creator.createToggleButtonCalled)
        XCTAssertFalse(ship.has(componentClassName: AccelerometerComponent.name))
        XCTAssertEqual(fireButton.sprite!.alpha, 0.2, accuracy: 0.0001)
    }

    func test_DoToggleButtons_ToShowingButtons_HasHyperspace() {
        let system = ShipControlsSystem(creator: creator)
        engine.addSystem(system: system, priority: 1)
        let appStateComponent = AppStateComponent(size: .zero,
                                                  ships: 0,
                                                  level: 0,
                                                  score: 0,
                                                  appState: .playing,
                                                  shipControlsState: .showingButtons)
        //TODO: do_toggleButtons requires the ShipEntity type as it uses engine.ship. 
        let ship = ShipEntity(name: .ship, state: appStateComponent, size: .zero)
                .add(component: AccelerometerComponent())
                .add(component: HyperspaceEngineComponent())
        try? engine.addEntity(entity: ship)
        let hyperspaceButton = Entity(name: .hyperspaceButton)
                .add(component: DisplayComponent(sknode: SwashSpriteNode()))
        try? engine.addEntity(entity: hyperspaceButton)
        //                
        system.do_toggleButtons(.showingButtons)
        XCTAssertTrue(creator.removeShipControlQuadrantsCalled)
        XCTAssertTrue(creator.createShipControlButtonsCalled)
        XCTAssertTrue(creator.enableShipControlButtonsCalled)
        XCTAssertTrue(creator.removeToggleButtonCalled)
        XCTAssertTrue(creator.createToggleButtonCalled)
        XCTAssertFalse(ship.has(componentClassName: AccelerometerComponent.name))
        XCTAssertEqual(hyperspaceButton.sprite!.alpha, 0.2, accuracy: 0.0001)
    }

    func test_DoToggleButtons_ToHidingButtons() {
        let system = ShipControlsSystem(creator: creator)
        engine.addSystem(system: system, priority: 1)
        let ship = Entity()
                .add(component: AccelerometerComponent())
                .add(component: GunComponent(offsetX: 0, offsetY: 0, minimumShotInterval: 0, torpedoLifetime: 0))
                .add(component: HyperspaceEngineComponent())
        try? engine.addEntity(entity: ship)
        //                
        system.do_toggleButtons(.hidingButtons)
        XCTAssertTrue(creator.removeShipControlQuadrantsCalled)
        XCTAssertTrue(creator.createShipControlButtonsCalled)
        XCTAssertTrue(creator.enableShipControlButtonsCalled)
        XCTAssertTrue(creator.removeToggleButtonCalled)
        XCTAssertTrue(creator.createToggleButtonCalled)
    }

    class MockCreator: ShipControlQuadrantsManager, ShipControlButtonsManager, ToggleButtonManager {
        var removeShipControlQuadrantsCalled = false
        var createShipControlQuadrantsCalled = false
        var removeShipControlButtonsCalled = false
        var createShipControlButtonsCalled = false
        var enableShipControlButtonsCalled = false
        var removeToggleButtonCalled = false
        var createToggleButtonCalled = false

        func removeShipControlQuadrants() {
            removeShipControlQuadrantsCalled = true
        }

        func createShipControlQuadrants() {
            createShipControlQuadrantsCalled = true
        }

        func removeShipControlButtons() {
            removeShipControlButtonsCalled = true
        }

        func createShipControlButtons() {
            createShipControlButtonsCalled = true
        }

        func enableShipControlButtons() {
            enableShipControlButtonsCalled = true
        }

        func removeToggleButton() {
            removeToggleButtonCalled = true
        }

        func createToggleButton(_ toggleState: Toggle) {
            createToggleButtonCalled = true
        }
    }
}

