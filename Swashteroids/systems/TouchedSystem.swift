//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import Foundation
import Swash
import SpriteKit

enum TouchState {
    case began
    case moved
    case ended
    case cancelled
    case none
}

class QuadrantComponent: Component {
    var quadrant: EntityName

    init(quadrant: EntityName) {
        self.quadrant = quadrant
    }
}

final class TouchedComponent: Component {
    var touch: Int
    var state: TouchState
    var locationInScene: CGPoint

    init(touch: Int, state: TouchState, locationInScene: CGPoint) {
        self.touch = touch
        self.state = state
        self.locationInScene = locationInScene
    }
}

class TouchedQuadrantNode: Node {
    required init() {
        super.init()
        components = [
            TouchedComponent.name: nil_component,
            QuadrantComponent.name: nil_component,
            DisplayComponent.name: nil_component,
            HapticFeedbackComponent.name: nil_component,
        ]
    }
}

class TouchedButtonNode: Node {
    required init() {
        super.init()
        components = [
            TouchedComponent.name: nil_component,
            ButtonComponent.name: nil_component,
            DisplayComponent.name: nil_component,
            HapticFeedbackComponent.name: nil_component,
        ]
    }
}

class TouchedButtonSystem: ListIteratingSystem {
    private weak var engine: Engine!

    init() {
        super.init(nodeClass: TouchedButtonNode.self)
        nodeUpdateFunction = updateNode
    }

    override public func addToEngine(engine: Engine) {
        super.addToEngine(engine: engine)
        self.engine = engine
    }

    override public func removeFromEngine(engine: Engine) {
        self.engine = nil
        super.removeFromEngine(engine: engine)
    }

    private func updateNode(node: Node, time: TimeInterval) {
        guard
            let touchedComponent = node[TouchedComponent.self],
            let displayComponent = node[DisplayComponent.self],
            let hapticFeedbackComponent = node[HapticFeedbackComponent.self],
            let sprite = displayComponent.sprite,
            let scene = sprite.scene,
            let buttonEntity = node.entity
        else { return }
        let location = touchedComponent.locationInScene

//        let location = touch.location(in: scene)
        let over = sprite.contains(location)

        // handle the button's functionality
        // HACK I've improved things from an ECS POV by pulling this code from the components into a system but I do not like the big if statement
        switch touchedComponent.state {
            case .began:
                if buttonEntity.has(componentClass: ButtonWithButtonsComponent.self) {
                    engine.gameStateEntity.add(component: ChangeGameStateComponent(from: .start, to: .infoButtons))
                } else if buttonEntity.has(componentClass: ButtonWithAccelerometerComponent.self) {
                    engine.gameStateEntity.add(component: ChangeGameStateComponent(from: .start, to: .infoNoButtons))
                } else if buttonEntity.has(componentClass: ButtonWithButtonsInfoComponent.self) {
                    engine.gameStateEntity.add(component: ChangeGameStateComponent(from: .infoButtons, to: .playing))
                } else if buttonEntity.has(componentClass: ButtonWithAccelerometerInfoComponent.self) {
                    engine.gameStateEntity.add(component: ChangeGameStateComponent(from: .infoNoButtons, to: .playing))
                } else if buttonEntity.has(componentClass: ButtonFireComponent.self) {
                    engine.playerEntity?.add(component: FireDownComponent.shared)
                } else if buttonEntity.has(componentClass: ButtonThrustComponent.self) {
                    if let ship = engine.playerEntity {
                        ship.add(component: ApplyThrustComponent.shared)
                        ship[WarpDriveComponent.self]?.isThrusting = true
                        ship[RepeatingAudioComponent.self]?.state = .shouldBegin
                    }
                } else if buttonEntity.has(componentClass: ButtonRightComponent.self) {
                    self.engine.playerEntity?.add(component: RightComponent.shared)
                } else if buttonEntity.has(componentClass: ButtonLeftComponent.self) {
                    self.engine.playerEntity?.add(component: LeftComponent.shared)
                } else if buttonEntity.has(componentClass: ButtonFlipComponent.self) {
                    engine.playerEntity?.add(component: FlipComponent.shared)
                } else if buttonEntity.has(componentClass: ButtonHyperSpaceComponent.self) {
                    engine.playerEntity?.add(component: DoHyperspaceJumpComponent(size: scene.size))
                } else if buttonEntity.has(componentClass: ButtonGameOverToHomeComponent.self) {
                    engine.playerEntity?.add(component: ChangeGameStateComponent(from: .gameOver, to: .start))
                } else if buttonEntity.has(componentClass: ButtonPauseComponent.self) {
                    buttonEntity.add(component: AlertPresentingComponent(state: .showPauseAlert))
                    print(self, "AlertPresentingComponent: showPauseAlert")
                } else if buttonEntity.has(componentClass: ButtonToggleComponent.self) {
                    let curState = engine.shipControlsState
                    let toggleState: Toggle = curState == .usingAccelerometer ? .off : .on
                    let toState: ShipControlsState = toggleState == .on ? .usingAccelerometer : .usingScreenControls
                    engine.gameStateComponent.shipControlsState = toState //HACK remove? Add TransitionAppStateComponent?
                    engine.hud?.add(component: ChangeShipControlsStateComponent(to: toState))
                    engine.hud?.add(component: AudioComponent(fileNamed: .toggle,
                                                              actionKey: "toggle\(toggleState.rawValue)"))
                }
            case .ended, .cancelled:
                if buttonEntity.has(componentClass: ButtonThrustComponent.self) {
                    if let playerEntity = engine.playerEntity {
                        playerEntity.remove(componentClass: ApplyThrustComponent.self)
                        playerEntity[WarpDriveComponent.self]?.isThrusting = false
                        playerEntity[RepeatingAudioComponent.self]?.state = .shouldStop
                    }
                } else if buttonEntity.has(componentClass: ButtonRightComponent.self) {
                    engine.playerEntity?.remove(componentClass: RightComponent.self)
                } else if buttonEntity.has(componentClass: ButtonLeftComponent.self) {
                    engine.playerEntity?.remove(componentClass: LeftComponent.self)
                }
            case .moved:
                if over {
                    if buttonEntity.has(componentClass: ButtonThrustComponent.self) {
                        if let playerEntity = engine.playerEntity {
                            playerEntity.add(component: ApplyThrustComponent.shared)
                            playerEntity[WarpDriveComponent.self]?.isThrusting = true
                            playerEntity[RepeatingAudioComponent.self]?.state = .shouldBegin
                        }
                    } else if buttonEntity.has(componentClass: ButtonRightComponent.self) {
                        engine.playerEntity?.add(component: RightComponent.shared)
                    } else if buttonEntity.has(componentClass: ButtonLeftComponent.self) {
                        engine.playerEntity?.add(component: LeftComponent.shared)
                    }
                } else {
                    if buttonEntity.has(componentClass: ButtonThrustComponent.self) {
                        if let playerEntity = engine.playerEntity,
                           playerEntity.has(componentClass: ApplyThrustComponent.self) {
                            playerEntity.remove(componentClass: ApplyThrustComponent.self)
                            playerEntity[WarpDriveComponent.self]?.isThrusting = false
                            playerEntity[RepeatingAudioComponent.self]?.state = .shouldStop
                        }
                    } else if buttonEntity.has(componentClass: ButtonRightComponent.self) {
                        engine.playerEntity?.remove(componentClass: RightComponent.self)
                    } else if buttonEntity.has(componentClass: ButtonLeftComponent.self) {
                        engine.playerEntity?.remove(componentClass: LeftComponent.self)
                    }
                }
            case .none:
                break
        }

        // handle the button's look and remove on ended
        switch touchedComponent.state {
            case .began:
                sprite.alpha = 0.6
                hapticFeedbackComponent.impact()
            case .ended, .cancelled:
                sprite.alpha = 0.2
                touchedComponents.removeValue(forKey: touchedComponent.touch)
                buttonEntity.remove(componentClass: TouchedComponent.self)
            case .moved:
                if over {
                    sprite.alpha = 0.6
                } else {
                    sprite.alpha = 0.2
                }
            case .none:
                break
        }

        touchedComponent.state = .none
    }
}

class TouchedQuadrantSystem: ListIteratingSystem {
    private weak var engine: Engine!

    init() {
        super.init(nodeClass: TouchedQuadrantNode.self)
        nodeUpdateFunction = updateNode
    }

    override public func addToEngine(engine: Engine) {
        super.addToEngine(engine: engine)
        self.engine = engine
    }

    override public func removeFromEngine(engine: Engine) {
        self.engine = nil
        super.removeFromEngine(engine: engine)
    }

    private func updateNode(node: Node, time: TimeInterval) {
        guard
            let quadrantComponent = node[QuadrantComponent.self],
            let touchedComponent = node[TouchedComponent.self],
            let displayComponent = node[DisplayComponent.self],
            let hapticFeedbackComponent = node[HapticFeedbackComponent.self],
            let sprite = displayComponent.sprite,
            let scene = sprite.scene,
            let buttonEntity = node.entity
        else { return }
        let location = touchedComponent.locationInScene
        let over = sprite.contains(location)
        switch touchedComponent.state {
            case .began:
                hapticFeedbackComponent.impact()
                switch quadrantComponent.quadrant {
                    case .q1:
                        if let ship = self.engine.playerEntity,
                           ship.has(componentClassName: HyperspaceDriveComponent.name) {
                            engine.playerEntity?.add(component: DoHyperspaceJumpComponent(size: scene.size))
                        }
                    case .q2:
                        engine.playerEntity?.add(component: FlipComponent.shared)
                    case .q3:
                        if let ship = self.engine.playerEntity {
                            ship.add(component: ApplyThrustComponent.shared)
                            ship[WarpDriveComponent.self]?.isThrusting = true
                            ship[RepeatingAudioComponent.self]?.state = .shouldBegin
                        }
                    case .q4:
                        engine.playerEntity?.add(component: FireDownComponent.shared)
                    default:
                        break
                }
            case .ended, .cancelled:
                buttonEntity.remove(componentClass: TouchedComponent.self)
                switch quadrantComponent.quadrant {
                    case .q3:
                        if let ship = self.engine.playerEntity {
                            ship.remove(componentClass: ApplyThrustComponent.self)
                            ship[WarpDriveComponent.self]?.isThrusting = false
                            ship[RepeatingAudioComponent.self]?.state = .shouldStop
                        }
                    default:
                        break
                }
            case .moved:
                if over {
                    switch quadrantComponent.quadrant {
                        case .q1:
                            if let ship = self.engine.playerEntity,
                               ship.has(componentClassName: HyperspaceDriveComponent.name) {
                                engine.playerEntity?.add(component: DoHyperspaceJumpComponent(size: scene.size))
                            }
                        case .q2:
                            engine.playerEntity?.add(component: FlipComponent.shared)
                        case .q3:
                            if let ship = self.engine.playerEntity {
                                ship.add(component: ApplyThrustComponent.shared)
                                ship[WarpDriveComponent.self]?.isThrusting = true
                                ship[RepeatingAudioComponent.self]?.state = .shouldBegin
                            }
                        case .q4:
                            engine.playerEntity?.add(component: FireDownComponent.shared)
                        default:
                            break
                    }
                } else {
                    switch quadrantComponent.quadrant {
                        case .q3:
                            if let ship = self.engine.playerEntity,
                               ship.has(componentClassName: ApplyThrustComponent.name) {
                                ship.remove(componentClass: ApplyThrustComponent.self)
                                ship[WarpDriveComponent.self]?.isThrusting = false
                                ship[RepeatingAudioComponent.self]?.state = .shouldStop
                            }
                        default:
                            break
                    }
                }
            case .none:
                break
        }
        touchedComponent.state = .none
    }
}
