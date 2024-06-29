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

class GamePadManager: NSObject {
    @Published var lastElementPressed: GCControllerElement?
    var mode: GamePadManagerMode = .game
    var previousTime = 0.0
    var timeSinceFired = 0.0
    var timeSinceFlip = 0.0
    var timeSinceHyperspace = 0.0
    weak var game: Swashteroids!
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
                buttonElements = allButtonElements(from: pad)
                dpadElements = allDpadElements(from: pad)
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

    var elementNameToGameCommand: [String: GameCommand] =
        [
            "Button A": .pause,
            "Button B": .resume,
            "Button X": .home,
            "Button Y": .settings,
            "Button Menu": .pause,
            "Button Options": .settings,
            "Direction Pad": .pause,
            "Left Shoulder": .pause,
            "Right Shoulder": .hyperspace,
            "Left Thumbstick": .left,
            "Right Thumbstick": .thrust,
            "Left Trigger": .flip,
            "Right Trigger": .fire,
            "Button Home": .pause
        ]

    private func controllerInputDetected(pad: GCExtendedGamepad, element: GCControllerElement) {
        lastElementPressed = element
        switch mode {
            case .game:
                for (buttonName, buttonInput) in buttonElements where element == buttonInput && buttonInput.isPressed {
                    if let command = elementNameToGameCommand[buttonName] {
                        execute(command)
                    }
                }
                for (dpadName, dpadInput) in dpadElements where element == dpadInput {
                    if let command = elementNameToGameCommand[dpadName] {
                        execute(command)
                    }
                }
            case .settings:
                break
        }
        switch game.engine.appStateComponent.swashteroidsState {
            case .start:
                handleStartState(pad: pad)
            case .infoButtons, .infoNoButtons:
                break
            case .gameOver:
                handleAlertState(pad: pad)
            case .playing:
                handleAlertState(pad: pad)
                handlePlayingState(pad: pad)
        }
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

        func turn_right() {
            if game.engine.ship?.has(componentClass: LeftComponent.self) == false {
                game.engine.ship?.add(component: RightComponent.shared)
            }
        }

        func turn_right_off() {
            game.engine.ship?.remove(componentClass: RightComponent.self)
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

        let deltaTime = game.currentTime - previousTime
        previousTime = game.currentTime
        timeSinceFired += deltaTime
        timeSinceFlip += deltaTime
        timeSinceHyperspace += deltaTime
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
    var buttonElements: [ElementName: GCControllerButtonInput] = [:]
    var dpadElements: [ElementName: GCControllerDirectionPad] = [:]

    func allButtonElements(from pad: GCExtendedGamepad) -> [ElementName: GCControllerButtonInput] {
        var elements: [ElementName: GCControllerButtonInput] = [:]
        elements["Button A"] = pad.buttonA
        elements["Button B"] = pad.buttonB
        elements["Button Menu"] = pad.buttonMenu
        elements["Button X"] = pad.buttonX
        elements["Button Y"] = pad.buttonY
        elements["Left Shoulder"] = pad.leftShoulder
        elements["Left Trigger"] = pad.leftTrigger
        elements["Right Shoulder"] = pad.rightShoulder
        elements["Right Trigger"] = pad.rightTrigger
        return elements
    }

    func allDpadElements(from pad: GCExtendedGamepad) -> [ElementName: GCControllerDirectionPad] {
        var elements: [ElementName: GCControllerDirectionPad] = [:]
        elements["Direction Pad"] = pad.dpad
        elements["Left Thumbstick"] = pad.leftThumbstick
        elements["Right Thumbstick"] = pad.rightThumbstick
        return elements
    }

    let elementNameToSymbolName: [ElementName: ElementSymbolName] = [
        "Button A": "a.circle",
        "Button B": "b.circle",
        "Button Menu": "line.horizontal.3.circle",
        "Button Options": "house.circle",
        "Button X": "x.circle",
        "Button Y": "y.circle",
        "Direction Pad": "dpad",
        "Left Shoulder": "l1.rectangle.roundedbottom",
        "Left Thumbstick": "l.joystick",
        "Left Trigger": "l2.rectangle.roundedtop",
        "Right Shoulder": "r1.rectangle.roundedbottom",
        "Right Thumbstick": "r.joystick",
        "Right Trigger": "r2.rectangle.roundedtop"
    ]

    private func printElementInfo(element: GCControllerElement) {
        print("----")
        print("Element:                 \(element)")
        print("localizedName:           \(element.localizedName!)")
        print("unmappedLocalizedName:   \(element.unmappedLocalizedName!)")
        print("sfSymbolsName:           \(element.sfSymbolsName!)")
        print("unmappedSfSymbolsName:   \(element.unmappedSfSymbolsName!)")
        print("aliases:                 \(element.aliases)")
        print("isAnalog:                \(element.isAnalog)")
        print("----")
    }
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


