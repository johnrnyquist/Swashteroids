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
    var creator: MockQuadrantsButtonToggleCreator!
    var engine: Engine!

    override func setUpWithError() throws {
        creator = MockQuadrantsButtonToggleCreator()
        engine = Engine()
    }

    override func tearDownWithError() throws {
        engine = nil
        creator = nil
    }

    func test_Init() throws {
        let system = ShipControlsSystem(toggleShipControlsCreator: creator,
                                        shipControlQuadrantsCreator: creator,
                                        shipButtonControlsCreator: creator)
        XCTAssertTrue(system.nodeClass == ShipControlsStateNode.self)
        XCTAssertNotNil(system.nodeUpdateFunction)
    }

    func test_UpdateNode() {
        let system = MockShipControlsSystem_DoToggleButtons(toggleShipControlsCreator: creator,
                                                            shipControlQuadrantsCreator: creator,
                                                            shipButtonControlsCreator: creator)
        let node = ShipControlsStateNode()
        let change = ChangeShipControlsStateComponent(to: .usingAccelerometer)
        node.components[ChangeShipControlsStateComponent.name] = change
        let entity = Entity()
                .add(component: change)
        node.entity = entity
        system.updateNode(node: node, time: 1.0)
        XCTAssertFalse(entity.has(componentClassName: ChangeShipControlsStateComponent.name))
        XCTAssertTrue(system.do_toggleButtonsCalled)

        class MockShipControlsSystem_DoToggleButtons: ShipControlsSystem {
            var do_toggleButtonsCalled = false

            override func handleChange(to: ShipControlsState) {
                do_toggleButtonsCalled = true
            }
        }
    }

    func test_DoToggleButtons_ToShowingButtons_NoGunNoHyperspace() {
        let system = ShipControlsSystem(toggleShipControlsCreator: creator,
                                        shipControlQuadrantsCreator: creator,
                                        shipButtonControlsCreator: creator)
        engine.add(system: system, priority: 1)
        //TODO: do_toggleButtons requires the ShipEntity type as it uses engine.ship. 
        let ship = Entity(named: .player)
                .add(component: AccelerometerComponent())
        engine.add(entity: ship)
        let appStateComponent = GameStateComponent(config: SwashteroidsConfig(gameSize: .zero))
        appStateComponent.numShips = 0
        appStateComponent.level = 0
        appStateComponent.shipControlsState = .usingAccelerometer
        let appState = Entity(named: .appState)
                .add(component: appStateComponent)
        engine.add(entity: appState)
        // SUT
        system.handleChange(to: .usingScreenControls)
        //
        XCTAssertTrue(creator.createShipControlButtonsCalled)
        XCTAssertTrue(creator.enableShipControlButtonsCalled)
        XCTAssertTrue(creator.removeToggleButtonCalled)
        XCTAssertTrue(creator.createToggleButtonCalled)
        XCTAssertFalse(ship.has(componentClassName: AccelerometerComponent.name))
    }

    func test_DoToggleButtons_ToShowingButtons_HasGun() {
        let system = ShipControlsSystem(toggleShipControlsCreator: creator,
                                        shipControlQuadrantsCreator: creator,
                                        shipButtonControlsCreator: creator)
        engine.add(system: system, priority: 1)
        //TODO: do_toggleButtons requires the ShipEntity type as it uses engine.ship. 
        let ship = Entity(named: .player)
        ship
                .add(component: AccelerometerComponent())
                .add(component: GunComponent(offsetX: 0,
                                             offsetY: 0,
                                             minimumShotInterval: 0,
                                             torpedoLifetime: 0,
                                             torpedoColor: .torpedo,
                                             ownerType: .player,
                                             ownerName: ship.name,
                                             numTorpedoes: 20))
        engine.add(entity: ship)
        let fireButton = Entity(named: .fireButton)
                .add(component: DisplayComponent(sknode: SwashSpriteNode()))
        engine.add(entity: fireButton)
        let appStateComponent = GameStateComponent(config: SwashteroidsConfig(gameSize: .zero))
        appStateComponent.numShips = 0
        appStateComponent.level = 0
        appStateComponent.shipControlsState = .usingAccelerometer
        let appState = Entity(named: .appState)
                .add(component: appStateComponent)
        engine.add(entity: appState)
        // SUT
        system.handleChange(to: .usingScreenControls)
        //
        XCTAssertTrue(creator.createShipControlButtonsCalled)
        XCTAssertTrue(creator.enableShipControlButtonsCalled)
        XCTAssertTrue(creator.removeToggleButtonCalled)
        XCTAssertTrue(creator.createToggleButtonCalled)
        XCTAssertFalse(ship.has(componentClassName: AccelerometerComponent.name))
        XCTAssertEqual(fireButton.sprite!.alpha, 0.2, accuracy: 0.0001)
    }

    func test_DoToggleButtons_ToShowingButtons_HasHyperspace() {
        let system = ShipControlsSystem(toggleShipControlsCreator: creator,
                                        shipControlQuadrantsCreator: creator,
                                        shipButtonControlsCreator: creator)
        engine.add(system: system, priority: 1)
        //TODO: do_toggleButtons requires the ShipEntity type as it uses engine.ship. 
        let ship = Entity(named: .player)
                .add(component: AccelerometerComponent())
                .add(component: HyperspaceDriveComponent(jumps: 20))
        engine.add(entity: ship)
        let hyperspaceButton = Entity(named: .hyperspaceButton)
                .add(component: DisplayComponent(sknode: SwashScaledSpriteNode()))
        engine.add(entity: hyperspaceButton)
        let appStateComponent = GameStateComponent(config: SwashteroidsConfig(gameSize: .zero))
        appStateComponent.numShips = 0
        appStateComponent.level = 0
        appStateComponent.shipControlsState = .usingAccelerometer
        let appState = Entity(named: .appState)
                .add(component: appStateComponent)
        engine.add(entity: appState)
        // SUT
        system.handleChange(to: .usingScreenControls)
        //
        XCTAssertTrue(creator.enableShipControlButtonsCalled)
        XCTAssertTrue(creator.removeToggleButtonCalled)
        XCTAssertTrue(creator.createToggleButtonCalled)
        XCTAssertFalse(ship.has(componentClassName: AccelerometerComponent.name))
        XCTAssertEqual(hyperspaceButton.sprite!.alpha, 0.2, accuracy: 0.0001)
    }

    func test_DoToggleButtons_ToHidingButtons() {
        let system = ShipControlsSystem(toggleShipControlsCreator: creator,
                                        shipControlQuadrantsCreator: creator,
                                        shipButtonControlsCreator: creator)
        engine.add(system: system, priority: 1)
        let ship = Entity()
        ship
                .add(component: AccelerometerComponent())
                .add(component: GunComponent(offsetX: 0,
                                             offsetY: 0,
                                             minimumShotInterval: 0,
                                             torpedoLifetime: 0,
                                             torpedoColor: .torpedo,
                                             ownerType: .player,
                                             ownerName: ship.name,
                                             numTorpedoes: 20))
                .add(component: HyperspaceDriveComponent(jumps: 20))
        engine.add(entity: ship)
        let appStateComponent = GameStateComponent(config: SwashteroidsConfig(gameSize: .zero))
        appStateComponent.numShips = 0
        appStateComponent.level = 0
        appStateComponent.shipControlsState = .usingAccelerometer

        let appState = Entity(named: .appState)
                .add(component: appStateComponent)
        engine.add(entity: appState)
        //
        system.handleChange(to: .usingAccelerometer)
        XCTAssertTrue(creator.createShipControlQuadrantsCalled)
        XCTAssertTrue(creator.removeShipControlButtonsCalled)
        XCTAssertTrue(creator.removeToggleButtonCalled)
        XCTAssertTrue(creator.createToggleButtonCalled)
        XCTAssertTrue(ship.has(componentClassName: AccelerometerComponent.name))
    }
}

