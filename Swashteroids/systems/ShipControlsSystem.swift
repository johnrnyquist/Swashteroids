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

class ShipControlsSystem: ListIteratingSystem {
    private weak var creator: (ShipControlQuadrantsManager & ShipControlButtonsManager & ToggleButtonManager)!
    private weak var engine: Engine!

    init(creator: ShipControlQuadrantsManager & ShipControlButtonsManager & ToggleButtonManager) {
        self.creator = creator
        super.init(nodeClass: ShipControlsStateNode.self)
        nodeUpdateFunction = updateNode
    }

    override func addToEngine(engine: Engine) {
        super.addToEngine(engine: engine)
        self.engine = engine
    }

    func updateNode(node: Node, time: TimeInterval) {
        guard let transition = node[ChangeShipControlsStateComponent.self]
        else { return }
        do_toggleButtons(transition.to)
        node.entity?.remove(componentClass: ChangeShipControlsStateComponent.self)
    }

    //HACK this whole method is a hack, the Law of Demeter is being violated.
    func do_toggleButtons(_ to: ShipControlsState) {
        switch to {
            case .showingButtons:
                engine.ship?.remove(componentClass: AccelerometerComponent.self)
                creator.removeShipControlQuadrants()
                creator.createShipControlButtons()
                creator.enableShipControlButtons()
                // HACK alpha for fire and hyperspace is set to 0.0 in Creator+ShipControlButtonsManager.swift
                if let ship = engine.ship,
                   ship.has(componentClassName: GunComponent.name) {
                    if let fireButton = engine.getEntity(named: .fireButton),
                       let sprite = fireButton.sprite {
                        sprite.alpha = 0.2
                    }
                }
                if let ship = engine.ship,
                   ship.has(componentClassName: HyperspaceEngineComponent.name) {
                    if let hyperspaceButton = engine.getEntity(named: .hyperspaceButton),
                       let sprite = hyperspaceButton.sprite {
                        sprite.alpha = 0.2
                    }
                }
                creator.removeToggleButton()
                creator.createToggleButton(.on)
            case .hidingButtons:
                engine.ship?.add(component: AccelerometerComponent())
                creator.createShipControlQuadrants()
                creator.removeShipControlButtons()
                creator.removeToggleButton()
                creator.createToggleButton(.off)
        }
    }
}

