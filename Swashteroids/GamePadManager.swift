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
import Combine
import GameController

enum GamePadManagerMode {
    case game
    case settings
}

class GamePadManager: NSObject, ObservableObject {
    @Published var lastElementPressed: String?
    weak var game: Swashteroids!
    var mode: GamePadManagerMode = .game
    var previousTime = 0.0
    var timeSinceFired = 0.0
    var timeSinceFlip = 0.0
    var timeSinceHyperspace = 0.0
    var size: CGSize

    init(game: Swashteroids, size: CGSize) {
        self.game = game
        self.size = size
        super.init()
        setupObservers()
    }

    deinit {
        print(self, #function)
        NotificationCenter.default.removeObserver(self)
    }

    private func setupObservers() {
        print(#function)
        NotificationCenter.default
                          .addObserver(self,
                                       selector: #selector(controllerDidConnect),
                                       name: NSNotification.Name.GCControllerDidConnect,
                                       object: nil)
        NotificationCenter.default
                          .addObserver(self,
                                       selector: #selector(controllerDidDisconnect),
                                       name: NSNotification.Name.GCControllerDidDisconnect,
                                       object: nil)
    }

    @objc private func controllerDidConnect() {
        print(#function)
        for controller in GCController.controllers() {
            print(controller.vendorName ?? "Unknown Vendor")
            //Check to see whether it is an extended Game Controller (Such as a Nimbus)
            if let pad = controller.extendedGamepad {
//                buttonElements = allButtonElements(from: pad)
//                dpadElements = allDpadElements(from: pad)
                game.engine.appStateEntity.add(component: GamePadComponent())
                game.usingGameController()
                pad.valueChangedHandler = controllerInputDetected
                if game.engine.appStateComponent.swashteroidsState == .infoButtons ||
                   game.engine.appStateComponent.swashteroidsState == .infoNoButtons {
                    (game.alertPresenter as? GameViewController)?.startNewGame() //HACK
                }
                break
            }
        }
    }

    @objc private func controllerDidDisconnect() {
        print(#function)
        game.engine.appStateEntity.remove(componentClass: GamePadComponent.self)
        game.usingScreenControls()
    }

    private func execute(_ command: GameCommand) {
        print(#function, command)
        switch command {
            case .fire:
                break
            case .thrust:
                break
            case .hyperspace:
                break
            case .left:
                break
            case .right:
                break
            case .pause:
                break
            case .flip:
                break
            case .home:
                break
            case .settings:
                break
            case .resume:
                break
            case .continue:
                break
            case .buttons:
                break
            case .noButtons:
                break
        }
    }

    func resolveInput(pad: GCExtendedGamepad, element: GCControllerElement) -> String? {
        print("ELEMENT NAME", element.localizedName!)
        var result: String? = nil
        if let button = element as? GCControllerButtonInput {
            if button.isPressed {
                print("button \(button.localizedName!) is pressed")
            } else {
                print("button \(button.localizedName!) is not pressed")
            }
            result = button.localizedName!
        } else if let dpad = element as? GCControllerDirectionPad {
            switch dpad {
                case pad.dpad:
                    if pad.dpad.left.isPressed {
                        print(pad.dpad.left.sfSymbolsName)
                        result = pad.dpad.left.localizedName
                    } else if pad.dpad.right.isPressed {
                        print(pad.dpad.right.sfSymbolsName)
                        result = pad.dpad.right.localizedName
                    } else if pad.dpad.up.isPressed {
                        print(pad.dpad.up.sfSymbolsName)
                        result = pad.dpad.up.localizedName
                    } else if pad.dpad.down.isPressed {
                        print(pad.dpad.down.sfSymbolsName)
                        result = pad.dpad.down.localizedName
                    } else {
                        print("no direction")
                    }
                case pad.leftThumbstick:
                    if pad.leftThumbstick.left.isPressed {
                        print(pad.leftThumbstick.left.sfSymbolsName)
                        result = pad.leftThumbstick.left.localizedName
                    } else if pad.leftThumbstick.right.isPressed {
                        print(pad.leftThumbstick.right.sfSymbolsName)
                        result = pad.leftThumbstick.right.localizedName
                    } else if pad.leftThumbstick.up.isPressed {
                        print(pad.leftThumbstick.up.sfSymbolsName)
                        result = pad.leftThumbstick.up.localizedName
                    } else if pad.leftThumbstick.down.isPressed {
                        print(pad.leftThumbstick.down.sfSymbolsName)
                        result = pad.leftThumbstick.down.localizedName
                    } else {
                        print("no direction")
                    }
                case pad.rightThumbstick:
                    print("rightThumbstick \(pad.rightThumbstick.localizedName!)")
                    if pad.rightThumbstick.left.isPressed {
                        print(pad.rightThumbstick.left.sfSymbolsName)
                        result = pad.rightThumbstick.left.localizedName
                    } else if pad.rightThumbstick.right.isPressed {
                        print(pad.rightThumbstick.right.sfSymbolsName)
                        result = pad.rightThumbstick.right.localizedName
                    } else if pad.rightThumbstick.up.isPressed {
                        print(pad.rightThumbstick.up.sfSymbolsName)
                        result = pad.rightThumbstick.up.localizedName
                    } else if pad.rightThumbstick.down.isPressed {
                        print(pad.rightThumbstick.down.sfSymbolsName)
                        result = pad.rightThumbstick.down.localizedName
                    } else {
                        print("no direction")
                    }
                default:
                    break
            }
        }
        return result
    }

    private func controllerInputDetected(pad: GCExtendedGamepad, element: GCControllerElement) {
        lastElementPressed = resolveInput(pad: pad, element: element)
//        switch mode {
//            case .game:
//                for (buttonName, buttonInput) in buttonElements where element == buttonInput && buttonInput.isPressed {
//                    if let command = elementNameToGameCommand[buttonName] {
//                        execute(command)
//                    }
//                }
//                for (dpadName, dpadInput) in dpadElements where element == dpadInput {
//                    if let command = elementNameToGameCommand[dpadName] {
//                        execute(command)
//                    }
//                }
//            case .settings:
//                break
//        }
//        switch game.engine.appStateComponent.swashteroidsState {
//            case .start:
//                handleStartState(pad: pad)
//            case .infoButtons, .infoNoButtons:
//                break
//            case .gameOver:
//                handleAlertState(pad: pad)
//            case .playing:
//                handleAlertState(pad: pad)
//                handlePlayingState(pad: pad)
//        }
    }

    private func handleStartState(pad: GCExtendedGamepad) {
        game.engine.appStateEntity.add(component: TransitionAppStateComponent(from: .start, to: .playing))
    }

    private func handleAlertState(pad: GCExtendedGamepad) {
        if game.alertPresenter.isAlertPresented == false,
           pad.buttonY.isPressed {
            game.alertPresenter.showPauseAlert()
            return
        } else if game.alertPresenter.isAlertPresented,
                  pad.buttonX.isPressed {
            game.alertPresenter.home()
            return
        } else if game.alertPresenter.isAlertPresented,
                  (pad.buttonB.isPressed || pad.buttonY.isPressed) {
            game.alertPresenter.resume()
            return
        }
    }

    private func handlePlayingState(pad: GCExtendedGamepad) {
        let deltaTime = game.currentTime - previousTime
        previousTime = game.currentTime
        timeSinceFired += deltaTime
        timeSinceFlip += deltaTime
        timeSinceHyperspace += deltaTime

        func hyperSpace() {
            if timeSinceHyperspace > 0.5 {
                timeSinceHyperspace = 0.0
                game.engine.ship?.add(component: DoHyperspaceJumpComponent(size: size))
            }
        }

        func flip() {
            if timeSinceFlip > 0.2 {
                timeSinceFlip = 0.0
                game.engine.ship?.add(component: FlipComponent.shared)
            }
        }

        func fire() {
            if timeSinceFired > 0.2 {
                timeSinceFired = 0.0
                game.engine.ship?.add(component: FireDownComponent.shared)
            }
        }

        func turn_left() {
            if game.engine.ship?.has(componentClass: RightComponent.self) == false {
                game.engine.ship?.add(component: LeftComponent.shared)
            }
        }

        func turn_right_off() {
            game.engine.ship?.remove(componentClass: RightComponent.self)
        }

        func turn_right() {
            if game.engine.ship?.has(componentClass: LeftComponent.self) == false {
                game.engine.ship?.add(component: RightComponent.shared)
            }
        }

        func turn_left_off() {
            game.engine.ship?.remove(componentClass: LeftComponent.self)
        }

        func thrust() {
            game.engine.ship?.add(component: ApplyThrustComponent.shared)
            game.engine.ship?[WarpDriveComponent.self]?.isThrusting = true
            game.engine.ship?[RepeatingAudioComponent.self]?.state = .shouldBegin
        }

        func thrust_off() {
            game.engine.ship?.remove(componentClass: ApplyThrustComponent.self)
            game.engine.ship?[WarpDriveComponent.self]?.isThrusting = false
            game.engine.ship?[RepeatingAudioComponent.self]?.state = .shouldStop
        }

        // HYPERSPACE
        if pad.rightShoulder.isPressed && pad.rightShoulder.value == 1.0 {
            hyperSpace()
        }
        // FLIP
        if pad.leftShoulder.isPressed && pad.leftShoulder.value == 1.0 {
            flip()
        }
        // FIRE
        if pad.rightTrigger.isPressed,
           pad.rightTrigger.value == 1.0 {
            fire()
        }
        // TURN LEFT
        if pad.leftThumbstick.left.isPressed || pad.dpad.left.isPressed {
            turn_left()
        } else {
            turn_left_off()
        }
        // TURN RIGHT
        if pad.leftThumbstick.right.isPressed || pad.dpad.right.isPressed {
            turn_right()
        } else {
            turn_right_off()
        }
        // THRUST
        if pad.rightThumbstick.up.isPressed {
            thrust()
        } else {
            thrust_off()
        }
    }

    typealias ElementName = String
    typealias ElementSymbolName = String

    @Published var gameCommandToElementName: [GameCommand: String?] = [
        .fire: "R2 Button",
        .thrust: "Right Thumbstick (Up)",
        .hyperspace: "R1 Button",
        .left: "Left Thumbstick (Left)",
        .right: "Left Thumbstick (Right)",
        .pause: "Menu Button",
        .flip: "L1 Button",
        .home: "X Button",
        .settings: "Y Button",
        .resume: "B Button",
        .continue: "A Button",
    ]
    @Published var elementNameToGameCommand: [String: GameCommand?] =
        [
            "A Button": .continue,
            "B Button": .resume,
            "X Button": .home,
            "Y Button": .settings,
            "Menu Button": .pause,
            "Options Button": .pause,
            "Direction Pad Left": .pause,
            "Direction Pad Right": .pause,
            "Direction Pad Up": .pause,
            "Direction Pad Downn": .pause,
            "L1 Button": .flip,
            "R1 Button": .hyperspace,
            "Left Thumbstick (Left)": .left,
            "Left Thumbstick (Right)": .right,
            "Left Thumbstick (Up)": nil,
            "Left Thumbstick (Down)": nil,
            "Left Thumbstick Button": .pause,
            "Right Thumbstick (Left)": nil,
            "Right Thumbstick (Right)": nil,
            "Right Thumbstick (Up)": .thrust,
            "Right Thumbstick (Down)": nil,
            "Right Thumbstick Button": .pause,
            "L2 Button": .flip,
            "R2 Button": .fire,
        ]
    let elementNameToSymbolName: [ElementName: ElementSymbolName] = [
        "A Button": "a.circle",
        "B Button": "b.circle",
        "Direction Pad": "dpad",
        "L1 Button": "l1.rectangle.roundedbottom",
        "L2 Button": "l2.rectangle.roundedtop",
        "Menu Button": "line.horizontal.3.circle",
        "Options Button": "house.circle",
        "R1 Button": "r1.rectangle.roundedbottom",
        "R2 Button": "r2.rectangle.roundedtop",
        "X Button": "x.circle",
        "Y Button": "y.circle",
        "Left Thumbstick (Left)": "l.joystick.tilt.left",
        "Left Thumbstick (Right)": "l.joystick.tilt.right",
        "Left Thumbstick (Up)": "l.joystick.tilt.up",
        "Left Thumbstick (Down)": "l.joystick.tilt.down",
        "Left Thumbstick Button": "l.joystick.press.down",
        "Right Thumbstick (Left)": "r.joystick.tilt.left",
        "Right Thumbstick (Right)": "r.joystick.tilt.right",
        "Right Thumbstick (Up)": "r.joystick.tilt.up",
        "Right Thumbstick (Down)": "r.joystick.tilt.down",
        "Right Thumbstick Button": "r.joystick.press.down",
        "Direction Pad (Left)": "dpad.left.filled",
        "Direction Pad (Right)": "dpad.right.filled",
        "Direction Pad (Up)": "dpad.up.filled",
        "Direction Pad (Downn)": "dpad.down.filled",
    ]
}

import Swash

class GamePadComponent: Component {
    var commands: [String] = []

    func add(command: String) {
        commands.append(command)
    }

    func remove(command: String) {
        if let index = commands.firstIndex(of: command) {
            commands.remove(at: index)
        }
    }

    func has(command: String) -> Bool {
        commands.contains(command)
    }

    func clear() {
        commands.removeAll()
    }
}


