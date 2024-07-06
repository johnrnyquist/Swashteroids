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

protocol GameStateObserver: AnyObject {
    func onGameStateChange(state: GameScreen)
}

enum GameCommand: String, CaseIterable {
    // Playing
    case fire = "Fire"
    case thrust = "Thrust"
    case hyperspace = "Hyperspace"
    case left = "Left"
    case right = "Right"
    case flip = "Flip"
    case pause = "Pause"
    // Alert
    case home = "Home"
    case resume = "Resume"
    case settings = "Settings"
    // Start
    // Info
    case play = "Play"
}

enum ButtonTypes {
    case inputWhileDown
    case inputOnce
}

let buttonTypes: [GameCommand: ButtonTypes] = [
    .fire: .inputOnce,
    .thrust: .inputWhileDown,
    .hyperspace: .inputOnce,
    .left: .inputWhileDown,
    .right: .inputWhileDown,
    .pause: .inputOnce,
    .flip: .inputOnce,
    .home: .inputOnce,
    .resume: .inputOnce,
    .settings: .inputOnce,
    .play: .inputOnce,
]

class GamepadInputManager: NSObject, ObservableObject, GameStateObserver {
    typealias ButtonName = String
    typealias SymbolName = String
    @Published var gameCommandToButtonName: [GameCommand: ButtonName?]
    @Published var lastPressedButton: GCControllerButtonInput?
    static let defaultMappings: [GameCommand: ButtonName?] = [
        // always available in game
        .left: "Left Thumbstick (Left)",
        .right: "Left Thumbstick (Right)",
        .thrust: "Right Thumbstick (Up)",
        .flip: "L2 Button",
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
    let dpadButtons = ["Direction Pad (Left)", "Direction Pad (Right)", "Direction Pad (Up)", "Direction Pad (Down)"]
    let leftThumbstickButtons = ["Left Thumbstick (Left)", "Left Thumbstick (Right)", "Left Thumbstick (Up)", "Left Thumbstick (Down)"]
    let rightThumbstickButtons = ["Right Thumbstick (Left)", "Right Thumbstick (Right)", "Right Thumbstick (Up)", "Right Thumbstick (Down)"]
    private var size: CGSize
    private var commandToClosure_alert: [GameCommand: GCControllerButtonValueChangedHandler] = [:]
    private var commandToClosure_playing: [GameCommand: GCControllerButtonValueChangedHandler] = [:]
    private var commandToClosure_start: [GameCommand: GCControllerButtonValueChangedHandler] = [:]
    var mode: CurrentViewController = .game
    weak var game: Swashteroids!
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
        gameCommandToButtonName = [:]
        super.init()
        setupObservers()
    }

    deinit {
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

    //HACK for updateMappings()
    var pad: GCExtendedGamepad {
        GCController.controllers().first!.extendedGamepad!
    }

    @objc private func controllerDidConnect() {
        controllers:
        for controller in GCController.controllers() {
            print("CONTROLLER DETECTED:", controller.vendorName ?? "Unknown Vendor")
            //Check to see whether it is an extended Game Controller (Such as a Nimbus)
            if let pad = controller.extendedGamepad {
                game.setGamepadInputManager(self)
                pad.valueChangedHandler = { [unowned self] (pad, element) in
                    if mode == .settings {
                        lastPressedButton = getButton(from: pad, element: element)
                    }
                }
                gameCommandToButtonName = loadSettings()
                updateMappings()
                break controllers
            }
        }
    }

    @objc private func controllerDidDisconnect() {
        game.setGamepadInputManager(nil)
    }

    func gameCommandToSymbolName(_ command: GameCommand) -> SymbolName? {
        guard let buttonName = gameCommandToButtonName[command],
              let buttonName else {
            return nil
        }
        return buttonNameToSymbolName[buttonName]
    }

    func updateMappings() {
        mapCommandsToClosures(using: gameCommandToButtonName)
        assignHandlersForCurrentState(pad: pad)
    }

    private func mapCommandsToClosures(using mappings: [GameCommand: ButtonName?]) {
        commandToClosure_playing = [:]
        commandToClosure_start = [:]
        commandToClosure_alert = [:]
        for (command, _) in mappings {
            commandToClosure_playing[command] = getHandlerPlayingState(command)
            commandToClosure_start[command] = getHandlerStartState()
            commandToClosure_alert[command] = getHandlerAlertState(command)
        }
    }

    func loadSettings() -> [GameCommand: ButtonName?] {
        var result: [GameCommand: ButtonName?]?
        if let retrievedDict = UserDefaults.standard.dictionary(forKey: "GameCommandDict") as? [String: String] {
            result = retrievedDict.compactMapKeys { GameCommand(rawValue: $0) }
            print("LOADED SETTINGS:", result ?? "nil")
        } else {
            print("NO SETTINGS FOUND, USING DEFAULTS")
        }
        var mappings: [GameCommand: ButtonName?]
        if let result {
            mappings = result
        } else {
            mappings = GamepadInputManager.defaultMappings
        }
        return mappings
    }

    private func findKey(forValue value: String, in dictionary: [GameCommand: ButtonName?]) -> GameCommand? {
        for (key, val) in dictionary {
            if val == value {
                return key
            }
        }
        return nil
    }

    func getButton(from pad: GCExtendedGamepad, element: GCControllerElement) -> GCControllerButtonInput? {
        var button: GCControllerButtonInput? = element as? GCControllerButtonInput
        if let button { // element is a button
            return button
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

    func onGameStateChange(state: GameScreen) {
        updateMappings()
    }

    private func assignClosuresToHandlers(pad: GCExtendedGamepad, dictionary: [GameCommand: GCControllerButtonValueChangedHandler]) {
        pad.allButtons.forEach { button in
            guard let command = gameCommandFromButtonName(button.localizedName!),
                  let handler = dictionary[command] else {
                return
            }
            button.pressedChangedHandler = handler
        }
    }

    func gameCommandFromButtonName(_ buttonName: String) -> GameCommand? {
        for (key, value) in gameCommandToButtonName where value == buttonName {
            if game.gameScreen.commandsPerScreen.contains(key) {
                return key
            }
        }
        return nil
    }

    // Centralized method to assign closures to handlers based on the current game state
    private func assignHandlersForCurrentState(pad: GCExtendedGamepad) {
        let dictionary = getDictionaryForCurrentState()
        setupHandlers(pad: pad, with: dictionary)
    }

    // Helper method to get the appropriate dictionary of closures based on the current game state
    private func getDictionaryForCurrentState() -> [GameCommand: GCControllerButtonValueChangedHandler] {
        switch game.gameScreen {
            case .start:
                return commandToClosure_start
            case .playing:
                return commandToClosure_playing
            default:
                return [:]
        }
    }

    // Generic method to setup handlers for a given pad and dictionary of commands to closures
    private func setupHandlers(pad: GCExtendedGamepad, with dictionary: [GameCommand: GCControllerButtonValueChangedHandler]) {
        setupDefaultHandlers(pad: pad) // clear existing
        pad.allButtons.forEach { button in
            if let command = gameCommandFromButtonName(button.localizedName!),
               let handler = dictionary[command] {
                button.pressedChangedHandler = handler
            }
        }
    }

    // Simplified default handlers setup, potentially for debugging or default actions
    private func setupDefaultHandlers(pad: GCExtendedGamepad) {
        pad.allButtons.forEach { button in
            button.pressedChangedHandler = { [unowned self] _, _, _ in
                print("Default handler for \(button.localizedName!)")
            }
        }
    }

    private func getHandlerStartState() -> GCControllerButtonValueChangedHandler {
        return { [weak self] (_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) -> Void in
            self?.game.engine.appStateEntity.add(component: ChangeGameStateComponent(from: .start, to: .playing))
        }
    }

    private func getHandlerAlertState(_ command: GameCommand) -> GCControllerButtonValueChangedHandler {
        switch command {
            case .home:
                return { [weak self] (_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) -> Void in
                    self?.game.alertPresenter.home() //HACK
                }
            case .settings:
                return { [weak self] (_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) -> Void in
                    self?.game.alertPresenter.showSettings() //HACK
                }
            case .resume:
                return { [weak self] (_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) -> Void in
                    self?.game.alertPresenter.resume() //HACK
                }
            default: break
        }
        return { (_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) -> Void in
            print("COMMAND \(command) NOT MAPPED")
        }
    }

    private func getHandlerPlayingState(_ command: GameCommand) -> GCControllerButtonValueChangedHandler {
        switch command {
            case .fire: return fire
            case .thrust: return thrust
            case .hyperspace: return hyperSpace
            case .left: return turn_left
            case .right: return turn_right
            case .pause: return pauseAlert
            case .flip: return flip
            default: break
        }
        return { (_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) -> Void in
            print("COMMAND \(command) NOT MAPPED")
        }
    }

    //MARK: - Game Commands
    private func fire(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) {
        if pressed {
            game.engine.playerEntity?.add(component: FireDownComponent.shared)
        }
    }

    private func hyperSpace(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) {
        if pressed {
            game.engine.playerEntity?.add(component: DoHyperspaceJumpComponent(size: size))
        }
    }

    private func flip(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) {
        if pressed {
            game.engine.playerEntity?.add(component: FlipComponent.shared)
        }
    }

    private func thrust(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) {
        if pressed {
            game.engine.playerEntity?.add(component: ApplyThrustComponent.shared)
            game.engine.playerEntity?[WarpDriveComponent.self]?.isThrusting = true
            game.engine.playerEntity?[RepeatingAudioComponent.self]?.state = .shouldBegin
        } else {
            game.engine.playerEntity?.remove(componentClass: ApplyThrustComponent.self)
            game.engine.playerEntity?[WarpDriveComponent.self]?.isThrusting = false
            game.engine.playerEntity?[RepeatingAudioComponent.self]?.state = .shouldStop
        }
    }

    private func turn_left(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) {
        if pressed {
            if game.engine.playerEntity?.has(componentClass: RightComponent.self) == false {
                game.engine.playerEntity?.add(component: LeftComponent.shared)
            }
        } else {
            game.engine.playerEntity?.remove(componentClass: LeftComponent.self)
        }
    }

    private func turn_right(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) {
        if pressed {
            if game.engine.playerEntity?.has(componentClass: LeftComponent.self) == false {
                game.engine.playerEntity?.add(component: RightComponent.shared)
            }
        } else {
            game.engine.playerEntity?.remove(componentClass: RightComponent.self)
        }
    }

    private func pauseAlert(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) {
        if pressed {
            game.alertPresenter.showPauseAlert() //HACK
        }
    }

    private func `continue`(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) {
        if pressed {
            game.engine.appStateEntity.add(component: ChangeGameStateComponent(from: .start, to: .playing))
        }
    }
}
