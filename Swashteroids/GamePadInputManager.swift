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

enum GameCommand: String, CaseIterable {
    // Playing
    case fire = "Fire"
    case thrust = "Thrust"
    case hyperspace = "Hyperspace"
    case left = "Left"
    case right = "Right"
    case pause = "Pause"
    case flip = "Flip"
    // Alert
    case home = "Home"
    case resume = "Resume"
    case settings = "Settings"
    // Start
    // Info
    case play = "Play"
}

class GamePadInputManager: NSObject, ObservableObject {
    @Published var gameCommandToButtonName: [GameCommand: String?] = GamePadInputManager.defaultMappings
    @Published var lastPressedButton: GCControllerButtonInput?

    func gameCommandToSymbolName(_ command: GameCommand) -> String? {
        guard let buttonName = gameCommandToButtonName[command],
              let buttonName else {
            return nil
        }
        return buttonNameToSymbolName[buttonName]
    }

    static let defaultMappings: [GameCommand: String?] = [
        // always available in game
        .left: "Left Thumbstick (Left)",
        .right: "Left Thumbstick (Right)",
        .thrust: "Right Thumbstick (Up)",
        .flip: "L1 Button",
        .pause: "A Button",
        // sometimes available in game. power ups
        .fire: "R2 Button",
        .hyperspace: "R1 Button",
        // when alert is up
        .home: "X Button",
        .resume: "B Button",
        .settings: "Menu Button",
        // start
        // info screens
        .play: "A Button",
    ]
    private var previousTime = 0.0
    private var size: CGSize
    var mode: CurrentViewController = .game
    weak var game: Swashteroids!
    typealias ButtonName = String
    typealias SymbolName = String
    let buttonNameToSymbolName: [ButtonName: SymbolName] = [
        "A Button": "a.circle",
        "B Button": "b.circle",
        "Direction Pad (Down)": "dpad.down.filled",
        "Direction Pad (Left)": "dpad.left.filled",
        "Direction Pad (Right)": "dpad.right.filled",
        "Direction Pad (Up)": "dpad.up.filled",
        "Direction Pad": "dpad",
        "L1 Button": "l1.rectangle.roundedbottom",
        "L2 Button": "l2.rectangle.roundedtop",
        "Left Thumbstick (Down)": "l.joystick.tilt.down",
        "Left Thumbstick (Left)": "l.joystick.tilt.left",
        "Left Thumbstick (Right)": "l.joystick.tilt.right",
        "Left Thumbstick (Up)": "l.joystick.tilt.up",
        "Left Thumbstick Button": "l.joystick.press.down",
        "Menu Button": "line.3.horizontal.circle",
        "Options Button": "house.circle",
        "R1 Button": "r1.rectangle.roundedbottom",
        "R2 Button": "r2.rectangle.roundedtop",
        "Right Thumbstick (Down)": "r.joystick.tilt.down",
        "Right Thumbstick (Left)": "r.joystick.tilt.left",
        "Right Thumbstick (Right)": "r.joystick.tilt.right",
        "Right Thumbstick (Up)": "r.joystick.tilt.up",
        "Right Thumbstick Button": "r.joystick.press.down",
        "X Button": "x.circle",
        "Y Button": "y.circle",
    ]

    init(game: Swashteroids, size: CGSize) {
        self.game = game
        self.size = size
        super.init()
        setupObservers()
        gameCommandToButtonName = loadSettings()
    }

    deinit {
        print(self, #function)
        NotificationCenter.default.removeObserver(self)
    }

    private func setupObservers() {
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

    func loadSettings() -> [GameCommand: String?] {
        let defaults = UserDefaults.standard
        var result: [GameCommand: String?]?
        if let retrievedDict = defaults.dictionary(forKey: "GameCommandDict") as? [String: String] {
            result = retrievedDict.compactMapKeys { GameCommand(rawValue: $0) }
            print("LOADED SETTINGS:", result ?? "nil")
        } else {
            print("NO SETTINGS FOUND, USING DEFAULTS")
        }
        return result ?? GamePadInputManager.defaultMappings
    }

    private func findKey(forValue value: String, in dictionary: [GameCommand: String?]) -> GameCommand? {
        print(#function, value)
        for (key, val) in dictionary {
            if val == value {
                return key
            }
        }
        return nil
    }

    @objc private func controllerDidConnect() {
        print(#function)
        for controller in GCController.controllers() {
            print(controller.vendorName ?? "Unknown Vendor")
            //Check to see whether it is an extended Game Controller (Such as a Nimbus)
            if let pad = controller.extendedGamepad {
                game.usingGameController()
                pad.valueChangedHandler = controllerInputDetected
                break
            }
        }
    }

    @objc private func controllerDidDisconnect() {
        print(#function)
        game.usingScreenControls()
    }

    func gameCommandFromButtonName(_ buttonName: String) -> GameCommand? {
        var keys = [GameCommand]()
        for (key, value) in gameCommandToButtonName {
            if value == buttonName {
                keys.append(key)
            }
        }
        let commands = game.gameState.commandsPerState
        for key in keys {
            if commands.contains(key) {
                return key
            }
        }
        return nil
    }

    private func controllerInputDetected(pad: GCExtendedGamepad, element: GCControllerElement) {
        lastPressedButton = getLastPressedName(pad: pad, element: element)
        print(lastPressedButton?.localizedName)
        guard let button = lastPressedButton, 
              let localizedName = button.localizedName,
              let command = gameCommandFromButtonName(localizedName)
        else { return }

        print(button.isPressed, button.value)
        print(command)
        execute(command: command, for: button)
        return
        for button in pad.allButtons {
            if let buttonName = button.localizedName,
               let command = findKey(forValue: buttonName, in: gameCommandToButtonName),
               game.gameState.commandsPerState.contains(command) {
                execute(command: command, for: button)
            }
        }
    }

    /// Returns the name of the last pressed button or dpad direction.
    /// If no button is pressed, returns nil.
    func getLastPressedName(pad: GCExtendedGamepad, element: GCControllerElement) -> GCControllerButtonInput? {
        var button: GCControllerButtonInput? = element as? GCControllerButtonInput
        if let button { // element is a button
            if button.isPressed {
                return button
            }
        } else if let dpad = element as? GCControllerDirectionPad { // element is a dpad
            switch dpad { // what kind of dpad
                case pad.dpad: // these are exclusive positions
                    if pad.dpad.left.isPressed {
                        button = pad.dpad.left
                    } else if pad.dpad.right.isPressed {
                        button = pad.dpad.right
                    } else if pad.dpad.up.isPressed {
                        button = pad.dpad.up
                    } else if pad.dpad.down.isPressed {
                        button = pad.dpad.down
                    }
                case pad.leftThumbstick: // these are non-exclusive positions
                    if pad.leftThumbstick.left.isPressed {
                        button = pad.leftThumbstick.left
                    }
                    if pad.leftThumbstick.right.isPressed {
                        button = pad.leftThumbstick.right
                    }
                    if pad.leftThumbstick.up.isPressed {
                        button = pad.leftThumbstick.up
                    }
                    if pad.leftThumbstick.down.isPressed {
                        button = pad.leftThumbstick.down
                    }
                case pad.rightThumbstick: // these are non-exclusive positions
                    if pad.rightThumbstick.left.isPressed {
                        button = pad.rightThumbstick.left
                    }
                    if pad.rightThumbstick.right.isPressed {
                        button = pad.rightThumbstick.right
                    }
                    if pad.rightThumbstick.up.isPressed {
                        button = pad.rightThumbstick.up
                    }
                    if pad.rightThumbstick.down.isPressed {
                        button = pad.rightThumbstick.down
                    }
                default:
                    break
            }
        }
        return button
    }

    private func handleStartState() {
        game.engine.gameStateEntity.add(component: TransitionAppStateComponent(from: .start, to: .playing))
    }

    private func handleAlertState(_ command: GameCommand) {
        if game.alertPresenter.isAlertPresented {
            switch command {
                case .home: game.alertPresenter.home() //HACK
                case .settings: game.alertPresenter.showSettings() //HACK
                case .resume: game.alertPresenter.resume() //HACK
                default: break
            }
        }
    }

    private func handlePlayingState(_ command: GameCommand, _ button: GCControllerButtonInput) {
        print(#function, command)
        switch command {
            case .fire: fire(button)
            case .thrust: thrust(button)
            case .hyperspace: hyperSpace(button)
            case .left: turn_left(button)
            case .right: turn_right(button)
            case .pause: pauseAlert(button)
            case .flip: flip(button)
            default: break
        }
    }

    /// Returns all buttons of an extended gamepad.
    //MARK: - Game Commands
    private func fire(_ button: GCControllerButtonInput) {
        if button.isPressed,
           button.value == 1.0 {
            game.engine.playerEntity?.add(component: FireDownComponent.shared)
        }
    }

    private func hyperSpace(_ button: GCControllerButtonInput) {
        if button.isPressed,
           button.value == 1.0 {
            game.engine.playerEntity?.add(component: DoHyperspaceJumpComponent(size: size))
        }
    }

    private func flip(_ button: GCControllerButtonInput) {
        if button.isPressed,
           button.value == 1.0 {
            game.engine.playerEntity?.add(component: FlipComponent.shared)
        }
    }

    private func thrust(_ button: GCControllerButtonInput) {
        if button.isPressed {
            game.engine.playerEntity?.add(component: ApplyThrustComponent.shared)
            game.engine.playerEntity?[WarpDriveComponent.self]?.isThrusting = true
            game.engine.playerEntity?[RepeatingAudioComponent.self]?.state = .shouldBegin
        } else {
            game.engine.playerEntity?.remove(componentClass: ApplyThrustComponent.self)
            game.engine.playerEntity?[WarpDriveComponent.self]?.isThrusting = false
            game.engine.playerEntity?[RepeatingAudioComponent.self]?.state = .shouldStop
        }
    }

    private func turn_left(_ button: GCControllerButtonInput) {
        if button.isPressed {
            if game.engine.playerEntity?.has(componentClass: RightComponent.self) == false {
                game.engine.playerEntity?.add(component: LeftComponent.shared)
            }
        } else {
            game.engine.playerEntity?.remove(componentClass: LeftComponent.self)
        }
    }

    private func turn_right(_ button: GCControllerButtonInput) {
        if button.isPressed {
            if game.engine.playerEntity?.has(componentClass: LeftComponent.self) == false {
                game.engine.playerEntity?.add(component: RightComponent.shared)
            }
        } else {
            game.engine.playerEntity?.remove(componentClass: RightComponent.self)
        }
    }

    private func pauseAlert(_ button: GCControllerButtonInput) {
        if button.isPressed {
            game.alertPresenter.showPauseAlert() //HACK
        }
    }

    private func `continue`(_ button: GCControllerButtonInput) {
        if button.isPressed {
            game.engine.gameStateEntity.add(component: TransitionAppStateComponent(from: .start, to: .playing))
        }
    }

    private func execute(command: GameCommand, for button: GCControllerButtonInput) {
        switch game.gameState {
            case .start:
                handleStartState()
            case .infoButtons, .infoNoButtons:
                handleStartState()
            case .gameOver:
                handleAlertState(command)
            case .playing:
                handleAlertState(command)
                handlePlayingState(command, button)
        }
    }
}
