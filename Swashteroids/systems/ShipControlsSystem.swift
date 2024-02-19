//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import Swash
import SpriteKit
import Foundation

/// This should be the place for all changes on the Ship’s controls
class ShipControlsSystem: ListIteratingSystem {
    private weak var creator: (ShipQuadrantsControlsManager & ShipButtonControlsManager & ToggleShipControlsManager)!
    private weak var engine: Engine!

    init(creator: ShipQuadrantsControlsManager & ShipButtonControlsManager & ToggleShipControlsManager) {
        self.creator = creator
        super.init(nodeClass: ShipControlsStateNode.self)
        nodeUpdateFunction = updateNode
    }

    override func addToEngine(engine: Engine) {
        super.addToEngine(engine: engine)
        self.engine = engine
    }

    func updateNode(node: Node, time: TimeInterval) {
        guard let change = node[ChangeShipControlsStateComponent.self]
        else { return }
        handleChange(to: change.destination)
        node.entity?.remove(componentClass: ChangeShipControlsStateComponent.self)
    }

    func handleChange(to: ShipControlsState) {
        engine.appStateComponent.shipControlsState = to
        switch to {
            case .showingButtons:
                showButtons()
            case .hidingButtons:
                engine.ship?.add(component: AccelerometerComponent())
                creator.createShipControlQuadrants()
                creator.removeShipControlButtons()
                creator.removeToggleButton()
                creator.createToggleButton(.off)
            case .usingScreenControls:
                print("ShipControlsSystem: showingScreenControls")
                showButtons()
                break
            case .usingGameController:
                print("ShipControlsSystem: hidingScreenControls")
                creator.removeShipControlQuadrants()
                engine.ship?.remove(componentClass: AccelerometerComponent.self)
                creator.removeShipControlButtons()
                creator.removeToggleButton()
                break
        }

        func showButtons() {
            engine.ship?.remove(componentClass: AccelerometerComponent.self)
            creator.removeShipControlQuadrants()
            creator.createShipControlButtons()
            creator.enableShipControlButtons()
            // HACK alpha for fire and hyperspace is set to 0.0 in Creator+ShipControlButtonsManager.swift
            if let ship = engine.ship,
               ship.has(componentClassName: GunComponent.name) {
                if let fireButton = engine.findEntity(named: .fireButton),
                   let sprite = fireButton.sprite {
                    sprite.alpha = 0.2
                }
            }
            if let ship = engine.ship,
               ship.has(componentClassName: HyperspaceDriveComponent.name) {
                if let hyperspaceButton = engine.findEntity(named: .hyperspaceButton),
                   let sprite = hyperspaceButton.sprite {
                    sprite.alpha = 0.2
                }
            }
            creator.removeToggleButton()
            creator.createToggleButton(.on)
        }
    }
}

