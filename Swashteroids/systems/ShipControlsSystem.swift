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
    private weak var shipControlQuadrantsCreator: QuadrantsControlsCreatorUseCase!
    private weak var shipButtonControlsCreator: ShipButtonCreatorUseCase!
    private let startButtonsCreator: StartScreenCreatorUseCase!

    init(toggleShipControlsCreator: ToggleShipControlsCreatorUseCase,
         shipControlQuadrantsCreator: QuadrantsControlsCreatorUseCase,
         shipButtonControlsCreator: ShipButtonCreatorUseCase,
         startButtonsCreator: StartScreenCreatorUseCase) {
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
                usingAccelerometer()
            case .usingScreenControls:
                usingScreenControls()
            case .usingGamepad:
                usingGamepad()
        }
    }

    private func usingScreenControls() {
        switch engine.gameStateComponent.gameScreen {
            case .start:
                startButtonsCreator.createStartButtons()
                startButtonsCreator.removeGamepadIndicator()
            case .playing:
                engine.playerEntity?.remove(componentClass: AccelerometerComponent.self)
                shipControlQuadrantsCreator.removeQuadrantControls()
                shipButtonControlsCreator.createShipControlButtons()
                shipButtonControlsCreator.enableShipControlButtons()
                //HACK alpha for fire and hyperspace is set to 0.0 in Creator+ShipControlButtonsManager.swift
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
                //END_HACK
                toggleShipControlsCreator.removeToggleButton()
                toggleShipControlsCreator.createToggleButton(.on)
            case .gameOver:
                break
            case .tutorial:
                break
        }
    }

    private func usingGamepad() {
        switch engine.gameStateComponent.gameScreen {
            case .start:
                startButtonsCreator.removeStartButtons()
                startButtonsCreator.createGamepadIndicator()
            case .playing:
                shipControlQuadrantsCreator.removeQuadrantControls()
                engine.playerEntity?.remove(componentClass: AccelerometerComponent.self)
                shipButtonControlsCreator.removeShipControlButtons()
                toggleShipControlsCreator.removeToggleButton()
            case .gameOver:
                break
            case .tutorial:
                break
        }
    }

    private func usingAccelerometer() {
        switch engine.gameStateComponent.gameScreen {
            case .start:
                startButtonsCreator.removeGamepadIndicator()
                startButtonsCreator.createStartButtons()
            case .playing:
                engine.playerEntity?.add(component: AccelerometerComponent.shared)
                shipControlQuadrantsCreator.createQuadrantControls()
                shipButtonControlsCreator.removeShipControlButtons()
                toggleShipControlsCreator.removeToggleButton()
                toggleShipControlsCreator.createToggleButton(.off)
            case .gameOver:
                break
            case .tutorial:
                break
        }
    }
}

