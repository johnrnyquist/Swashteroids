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
    private weak var engine: Engine!
    private weak var toggleShipControlsCreator: ToggleShipControlsCreatorUseCase!
    private weak var shipControlQuadrantsCreator: ShipQuadrantsControlsCreatorUseCase!
    private weak var shipButtonControlsCreator: ShipButtonControlsCreatorUseCase!
    private let startButtonsCreator: StartButtonsCreatorUseCase!

    init(toggleShipControlsCreator: ToggleShipControlsCreatorUseCase,
         shipControlQuadrantsCreator: ShipQuadrantsControlsCreatorUseCase,
         shipButtonControlsCreator: ShipButtonControlsCreatorUseCase,
         startButtonsCreator: StartButtonsCreatorUseCase) {
        self.toggleShipControlsCreator = toggleShipControlsCreator
        self.shipControlQuadrantsCreator = shipControlQuadrantsCreator
        self.shipButtonControlsCreator = shipButtonControlsCreator
        self.startButtonsCreator = startButtonsCreator
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
        engine.gameStateComponent.shipControlsState = to
        switch to {
            case .usingAccelerometer:
                print("ShipControlsSystem: usingAccelerometer")
                usingAccelerometer()
            case .usingScreenControls:
                print("ShipControlsSystem: usingScreenControls")
                usingScreenControls()
                break
            case .usingGameController:
                print("ShipControlsSystem: usingGameController")
                usingGameController()
                break
        }
    }

    private func usingScreenControls() {
        if engine.gameStateComponent.gameState == .playing {
            engine.playerEntity?.remove(componentClass: AccelerometerComponent.self)
            shipControlQuadrantsCreator.removeShipControlQuadrants()
            shipButtonControlsCreator.createShipControlButtons()
            shipButtonControlsCreator.enableShipControlButtons()
            // HACK alpha for fire and hyperspace is set to 0.0 in Creator+ShipControlButtonsManager.swift
            if let ship = engine.playerEntity,
               ship.has(componentClassName: GunComponent.name) {
                if let fireButton = engine.findEntity(named: .fireButton),
                   let sprite = fireButton.sprite {
                    sprite.alpha = 0.2
                }
            }
            if let ship = engine.playerEntity,
               ship.has(componentClassName: HyperspaceDriveComponent.name) {
                if let hyperspaceButton = engine.findEntity(named: .hyperspaceButton),
                   let sprite = hyperspaceButton.sprite {
                    sprite.alpha = 0.2
                }
            }
            toggleShipControlsCreator.removeToggleButton()
            toggleShipControlsCreator.createToggleButton(.on)
        }
    }

    private func usingGameController() {
        shipControlQuadrantsCreator.removeShipControlQuadrants()
        engine.playerEntity?.remove(componentClass: AccelerometerComponent.self)
        shipButtonControlsCreator.removeShipControlButtons()
        toggleShipControlsCreator.removeToggleButton()
        startButtonsCreator.removeStartButtons()
    }

    private func usingAccelerometer() {
        if engine.gameStateComponent.gameState == .playing {
            engine.playerEntity?.add(component: AccelerometerComponent())
            shipControlQuadrantsCreator.createShipControlQuadrants()
            shipButtonControlsCreator.removeShipControlButtons()
            toggleShipControlsCreator.removeToggleButton()
            toggleShipControlsCreator.createToggleButton(.off)
        }
    }
}

