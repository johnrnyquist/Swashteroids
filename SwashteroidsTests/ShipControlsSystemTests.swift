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
        engine.add(system: system, priority: 1)
        //TODO: do_toggleButtons requires the ShipEntity type as it uses engine.ship. 
        let ship = Entity(named: .ship)
                .add(component: AccelerometerComponent())
        try? engine.add(entity: ship)
        // SUT    
        system.do_toggleButtons(.showingButtons)
        //
        XCTAssertTrue(creator.createShipControlButtonsCalled)
        XCTAssertTrue(creator.enableShipControlButtonsCalled)
        XCTAssertTrue(creator.removeToggleButtonCalled)
        XCTAssertTrue(creator.createToggleButtonCalled)
        XCTAssertFalse(ship.has(componentClassName: AccelerometerComponent.name))
    }

    func test_DoToggleButtons_ToShowingButtons_HasGun() {
        let system = ShipControlsSystem(creator: creator)
        engine.add(system: system, priority: 1)
        //TODO: do_toggleButtons requires the ShipEntity type as it uses engine.ship. 
        let ship = Entity(named: .ship)
                .add(component: AccelerometerComponent())
                .add(component: GunComponent(offsetX: <#T##Double##Swift.Double#>,
                                             offsetY: <#T##Double##Swift.Double#>,
                                             minimumShotInterval: <#T##TimeInterval##Foundation.TimeInterval#>,
                                             torpedoLifetime: <#T##TimeInterval##Foundation.TimeInterval#>,
                                             torpedoColor: .torpedo,
                                             ownerType: <#T##OwnerType##Swashteroids.OwnerType#>,
                                             ammo: <#T##Int##Swift.Int#>))
        try? engine.add(entity: ship)
        let fireButton = Entity(named: .fireButton)
                .add(component: DisplayComponent(sknode: SwashSpriteNode()))
        try? engine.add(entity: fireButton)
        // SUT
        system.do_toggleButtons(.showingButtons)
        //
        XCTAssertTrue(creator.createShipControlButtonsCalled)
        XCTAssertTrue(creator.enableShipControlButtonsCalled)
        XCTAssertTrue(creator.removeToggleButtonCalled)
        XCTAssertTrue(creator.createToggleButtonCalled)
        XCTAssertFalse(ship.has(componentClassName: AccelerometerComponent.name))
        XCTAssertEqual(fireButton.sprite!.alpha, 0.2, accuracy: 0.0001)
    }

    func test_DoToggleButtons_ToShowingButtons_HasHyperspace() {
        let system = ShipControlsSystem(creator: creator)
        engine.add(system: system, priority: 1)
        //TODO: do_toggleButtons requires the ShipEntity type as it uses engine.ship. 
        let ship = Entity(named: .ship)
                .add(component: AccelerometerComponent())
                .add(component: HyperspaceDriveComponent())
        try? engine.add(entity: ship)
        let hyperspaceButton = Entity(named: .hyperspaceButton)
                .add(component: DisplayComponent(sknode: SwashSpriteNode()))
        try? engine.add(entity: hyperspaceButton)
        // SUT  
        system.do_toggleButtons(.showingButtons)
        //
        XCTAssertTrue(creator.enableShipControlButtonsCalled)
        XCTAssertTrue(creator.removeToggleButtonCalled)
        XCTAssertTrue(creator.createToggleButtonCalled)
        XCTAssertFalse(ship.has(componentClassName: AccelerometerComponent.name))
        XCTAssertEqual(hyperspaceButton.sprite!.alpha, 0.2, accuracy: 0.0001)
    }

    func test_DoToggleButtons_ToHidingButtons() {
        let system = ShipControlsSystem(creator: creator)
        engine.add(system: system, priority: 1)
        let ship = Entity()
                .add(component: AccelerometerComponent())
                .add(component: GunComponent(offsetX: <#T##Double##Swift.Double#>,
                                             offsetY: <#T##Double##Swift.Double#>,
                                             minimumShotInterval: <#T##TimeInterval##Foundation.TimeInterval#>,
                                             torpedoLifetime: <#T##TimeInterval##Foundation.TimeInterval#>,
                                             torpedoColor: .torpedo,
                                             ownerType: <#T##OwnerType##Swashteroids.OwnerType#>,
                                             ammo: <#T##Int##Swift.Int#>))
                .add(component: HyperspaceDriveComponent())
        try? engine.add(entity: ship)
        //                
        system.do_toggleButtons(.hidingButtons)
        XCTAssertTrue(creator.createShipControlQuadrantsCalled)
        XCTAssertTrue(creator.removeShipControlButtonsCalled)
        XCTAssertTrue(creator.removeToggleButtonCalled)
        XCTAssertTrue(creator.createToggleButtonCalled)
        XCTAssertTrue(ship.has(componentClassName: AccelerometerComponent.name))    
    }

    class MockCreator: ShipQuadrantsControlsManager, ShipButtonControlsManager, ToggleShipControlsManager {
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

