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

final class GamepadManager: NSObject, ObservableObject, GameStateObserver {
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
    weak var game: Swashteroids?
    var mode: CurrentViewController = .game
    var pad: GCExtendedGamepad? //HACK for updateMappings()
    private var size: CGSize
    private var commandToClosure_alert: [GameCommand: GCControllerButtonValueChangedHandler] = [:]
    private var commandToClosure_playing: [GameCommand: GCControllerButtonValueChangedHandler] = [:]
    private var commandToClosure_start: [GameCommand: GCControllerButtonValueChangedHandler] = [:]
    private let buttonNameToSymbolName: [ButtonName: SymbolName] = [
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

    @objc func controllerDidConnect() {
        controllers:
        for controller in GCController.controllers() {
            print("CONTROLLER DETECTED:", controller.vendorName ?? "Unknown Vendor")
            //Check to see whether it is an extended Game Controller (Such as a Nimbus)
            if let pad = controller.extendedGamepad,
               controller.isAttachedToDevice {
                self.pad = pad
                game?.setGamepadInputManager(self)
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

    @objc func controllerDidDisconnect() {
        pad = nil
        game?.setGamepadInputManager(nil)
    }

    /// Maps a game command to a button name
    func gameCommandToSymbolName(_ command: GameCommand) -> SymbolName? {
        guard let buttonName = gameCommandToButtonName[command],
              let buttonName else {
            return nil
        }
        return buttonNameToSymbolName[buttonName]
    }

    /// Maps a button name to a game command
    func updateMappings() {
        mapCommandsToClosures(using: gameCommandToButtonName)
        if let pad {
            assignHandlersForCurrentState(pad: pad)
        }
    }

    /// Saves the current game command to button name mappings to UserDefaults
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
            mappings = GamepadManager.defaultMappings
        }
        return mappings
    }

    /// Handles the change in game state
    func onGameStateChange(state: GameScreen) {
        updateMappings()
    }

    /// Clears any previous assignment of the button with the given localizedName
    func clearPreviousAssignment(for localizedName: String) {
        for (command, buttonName) in gameCommandToButtonName
            where game?.gameScreen.commandsPerScreen.contains(command) ?? false && buttonName == localizedName {
            gameCommandToButtonName.updateValue(nil, forKey: command)
        }
    }

    /// Assigns a button with the given localizedName to a specific command
    func assignButton(_ localizedName: String, to command: GameCommand) {
        gameCommandToButtonName[command] = localizedName
    }

    /// Sets up observers for controller connection and disconnection
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

    /// Maps commands to closures based on the current game state
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

    /// Gets the button from a pad and element
    private func getButton(from pad: GCExtendedGamepad, element: GCControllerElement) -> GCControllerButtonInput? {
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

    /// Retrieves the `GameCommand` associated with a given button name.
    ///
    /// This function searches through the `gameCommandToButtonName` dictionary to find a command whose assigned button name matches the provided `buttonName`. It also ensures that the command is relevant to the current game screen by checking if the command is contained within the `commandsPerScreen` array of the current `gameScreen` of the game.
    ///
    /// - Parameter buttonName: The localized name of the button for which to find the corresponding `GameCommand`.
    /// - Returns: The `GameCommand` associated with the given button name if found and relevant to the current game screen; otherwise, `nil`.
    private func gameCommandFromButtonName(_ buttonName: String) -> GameCommand? {
        gameCommandToButtonName.first { $1 == buttonName && game?.gameScreen.commandsPerScreen.contains($0) == true }?.key
    }

    /// Assigns button press handlers to the gamepad based on the provided dictionary of game commands to closures.
    ///
    /// This method iterates through all buttons on the provided gamepad (`pad`) and assigns them the corresponding button press handler from the `dictionary`. The dictionary maps `GameCommand` values to their respective `GCControllerButtonValueChangedHandler` closures, which define the actions to be taken when the button associated with a command is pressed or released.
    ///
    /// - Parameters:
    ///   - pad: The `GCExtendedGamepad` instance representing the game controller to which the handlers are to be assigned.
    ///   - dictionary: A dictionary mapping `GameCommand` values to their corresponding `GCControllerButtonValueChangedHandler` closures.
    private func assignClosuresToHandlers(pad: GCExtendedGamepad, dictionary: [GameCommand: GCControllerButtonValueChangedHandler]) {
        pad.allButtons.forEach { button in
            guard let command = gameCommandFromButtonName(button.localizedName!),
                  let handler = dictionary[command] else {
                return
            }
            button.pressedChangedHandler = handler
        }
    }

    // Centralized method to assign closures to handlers based on the current game state
    private func assignHandlersForCurrentState(pad: GCExtendedGamepad) {
        let dictionary = getDictionaryForCurrentState()
        setupHandlers(pad: pad, with: dictionary)
    }

    // Helper method to get the appropriate dictionary of closures based on the current game state
    private func getDictionaryForCurrentState() -> [GameCommand: GCControllerButtonValueChangedHandler] {
        guard let game else { return [:] }
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
            button.pressedChangedHandler = { _, _, _ in
                print("Default handler for \(button.localizedName!)")
            }
        }
    }

    /// Creates and returns a button value changed handler for the start state of the game.
    ///
    /// This handler is designed to transition the game from the start state to the playing state
    /// when a button is pressed. It encapsulates the logic necessary to initiate gameplay,
    /// effectively serving as a "start game" action when the player interacts with the gamepad.
    ///
    /// - Returns: A `GCControllerButtonValueChangedHandler` that, when invoked, changes the game state
    ///            from start to playing, allowing the game to commence.
    private func getHandlerStartState() -> GCControllerButtonValueChangedHandler {
        return { [weak self] (_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) -> Void in
            self?.game?.engine.appStateEntity.add(component: ChangeGameStateComponent(from: .start, to: .playing))
        }
    }

    /// Returns a button value changed handler specific to the alert state of the game.
    ///
    /// This function generates a closure that is executed when a button associated with a specific `GameCommand` is pressed or released during an alert state, such as showing the home screen, settings, or resuming the game. The handler's behavior varies depending on the command provided.
    ///
    /// - Parameter command: The `GameCommand` for which the handler is being requested.
    /// - Returns: A `GCControllerButtonValueChangedHandler` closure that performs the action associated with the given `GameCommand` during an alert state.
    private func getHandlerAlertState(_ command: GameCommand) -> GCControllerButtonValueChangedHandler {
        switch command {
            case .home:
                return { [weak self] (_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) -> Void in
                    self?.game?.alertPresenter.home() //HACK
                }
            case .settings:
                return { [weak self] (_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) -> Void in
                    self?.game?.alertPresenter.showSettings() //HACK
                }
            case .resume:
                return { [weak self] (_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) -> Void in
                    self?.game?.alertPresenter.resume() //HACK
                }
            default: break
        }
        return { (_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) -> Void in
            print("COMMAND \(command) NOT MAPPED")
        }
    }

    /// Returns a button value changed handler specific to the playing state of the game.
    ///
    /// This function generates a closure that is executed when a button associated with a specific `GameCommand` is pressed or released during the playing state of the game. The behavior of the handler varies depending on the command provided, executing different actions such as firing, thrusting, hyperspace jump, turning left or right, pausing, or flipping the ship.
    ///
    /// - Parameter command: The `GameCommand` for which the handler is being requested.
    /// - Returns: A `GCControllerButtonValueChangedHandler` closure that performs the action associated with the given `GameCommand` during the playing state.
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
            game?.engine.playerEntity?.add(component: FireDownComponent.shared)
        }
    }

    private func hyperSpace(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) {
        if pressed {
            game?.engine.playerEntity?.add(component: DoHyperspaceJumpComponent(size: size))
        }
    }

    private func flip(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) {
        if pressed {
            game?.engine.playerEntity?.add(component: FlipComponent.shared)
        }
    }

    private func thrust(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) {
        if pressed {
            game?.engine.playerEntity?.add(component: ApplyThrustComponent.shared)
            game?.engine.playerEntity?[ImpulseDriveComponent.self]?.isThrusting = true
            game?.engine.playerEntity?[RepeatingAudioComponent.self]?.state = .shouldBegin
        } else {
            game?.engine.playerEntity?.remove(componentClass: ApplyThrustComponent.self)
            game?.engine.playerEntity?[ImpulseDriveComponent.self]?.isThrusting = false
            game?.engine.playerEntity?[RepeatingAudioComponent.self]?.state = .shouldStop
        }
    }

    private func turn_left(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) {
        if pressed {
            if game?.engine.playerEntity?.has(componentClass: RightComponent.self) == false {
                game?.engine.playerEntity?.add(component: LeftComponent.shared)
            }
        } else {
            game?.engine.playerEntity?.remove(componentClass: LeftComponent.self)
        }
    }

    private func turn_right(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) {
        if pressed {
            if game?.engine.playerEntity?.has(componentClass: LeftComponent.self) == false {
                game?.engine.playerEntity?.add(component: RightComponent.shared)
            }
        } else {
            game?.engine.playerEntity?.remove(componentClass: RightComponent.self)
        }
    }

    private func pauseAlert(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) {
        if pressed {
            game?.alertPresenter.showPauseAlert() //HACK
        }
    }

    private func `continue`(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) {
        if pressed {
            game?.engine.appStateEntity.add(component: ChangeGameStateComponent(from: .start, to: .playing))
        }
    }
}
