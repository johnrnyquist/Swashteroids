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
    let id: Int
    let num: Int
    var processed = false
    var requestedEnd = false
    private var _state: TouchState
    var state: TouchState {
        set {
            if processed {
                _state = newValue
            } else if newValue == .ended || newValue == .cancelled {
                requestedEnd = true
            }
        }
        get { _state }
    }
    let firstLocation: CGPoint
    var locationInScene: CGPoint

    init(id: Int, num: Int, state: TouchState, locationInScene: CGPoint) {
        self.id = id
        self.num = num
        self._state = state
        self.firstLocation = locationInScene
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
    private weak var touchManager: TouchManager!

    init(touchManager: TouchManager) {
        self.touchManager = touchManager
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
        let over = sprite.contains(location)
        // handle the button's functionality
        // HACK I've improved things from an ECS POV by pulling this code from the components into a system but I do not like the big if statement
        switch touchedComponent.state {
            case .began:
                if buttonEntity.has(componentClass: ButtonWithButtonsComponent.self) {
                    engine.appStateEntity.add(component: ChangeGameStateComponent(from: .start, to: .infoButtons))
                } else if buttonEntity.has(componentClass: ButtonWithAccelerometerComponent.self) {
                    engine.appStateEntity.add(component: ChangeGameStateComponent(from: .start, to: .infoAccelerometer))
                } else if buttonEntity.has(componentClass: ButtonWithButtonsInfoComponent.self) {
                    engine.appStateEntity.add(component: ChangeGameStateComponent(from: .infoButtons, to: .playing))
                } else if buttonEntity.has(componentClass: ButtonWithAccelerometerInfoComponent.self) {
                    engine.appStateEntity.add(component: ChangeGameStateComponent(from: .infoAccelerometer, to: .playing))
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
                    engine.appStateEntity.add(component: ChangeGameStateComponent(from: .gameOver, to: .start))
                } else if buttonEntity.has(componentClass: ButtonPauseComponent.self) {
                    buttonEntity.add(component: AlertPresentingComponent(state: .showPauseAlert))
                } else if buttonEntity.has(componentClass: ButtonToggleComponent.self) {
                    let curState = engine.shipControlsState
                    let toggleState: Toggle = curState == .usingAccelerometer ? .off : .on
                    let toState: ShipControlsState = toggleState == .on ? .usingAccelerometer : .usingScreenControls
                    engine.gameStateComponent.shipControlsState = toState //HACK remove? Add TransitionAppStateComponent?
                    engine.hud?.add(component: ChangeShipControlsStateComponent(to: toState))
                    engine.hud?.add(component: AudioComponent(name: "toggle\(toggleState.rawValue)", fileName: .toggle))
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
                touchedComponent.processed = true
                if touchedComponent.requestedEnd {
                    touchedComponent.state = .ended
                } else {
                    touchedComponent.state = .none
                }
            case .ended, .cancelled:
                guard touchedComponent.processed
                else { return }
                sprite.alpha = 0.2
                touchManager.remove(touchedComponent.id)
                buttonEntity.remove(componentClass: TouchedComponent.self)
            case .moved:
                if over {
                    sprite.alpha = 0.6
                } else {
                    sprite.alpha = 0.2
                }
                touchedComponent.state = .none
            case .none:
                if touchedComponent.requestedEnd {
                    touchedComponent.state = .ended
                }
                break
        }
    }
}

class TouchedQuadrantSystem: ListIteratingSystem {
    private weak var engine: Engine!
    private weak var touchManager: TouchManager!

    init(touchManager: TouchManager) {
        self.touchManager = touchManager
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
                switch quadrantComponent.quadrant {
                    case .q1:
                        //TODO: Should this check be here?
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
                } else {
                }
            case .none:
                break
        }

        switch touchedComponent.state {
            case .began:
                hapticFeedbackComponent.impact()
                touchedComponent.processed = true
                if touchedComponent.requestedEnd {
                    touchedComponent.state = .ended
                } else {
                    touchedComponent.state = .none
                }
            case .ended, .cancelled:
                guard touchedComponent.processed
                else { return }
                touchManager.remove(touchedComponent.id)
                buttonEntity.remove(componentClass: TouchedComponent.self)
            case .moved:
                if over {
                } else {
                }
                touchedComponent.state = .none
            case .none:
                if touchedComponent.requestedEnd {
                    touchedComponent.state = .ended
                }
                break
        }

    }
}
