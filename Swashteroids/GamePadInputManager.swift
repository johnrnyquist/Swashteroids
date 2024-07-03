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

protocol GameStateObserver {
    func onGameStateChange(state: GameState)
}

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

class GamePadInputManager: NSObject, ObservableObject, GameStateObserver {
    typealias ButtonName = String
    typealias SymbolName = String
    @Published var gameCommandToButtonName: [GameCommand: ButtonName?] = defaultMappings
    @Published var lastPressedButton: GCControllerButtonInput?

    func gameCommandToSymbolName(_ command: GameCommand) -> SymbolName? {
        guard let buttonName = gameCommandToButtonName[command],
              let buttonName else {
            return nil
        }
        return buttonNameToSymbolName[buttonName]
    }

    static let defaultMappings: [GameCommand: ButtonName?] = [
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
    private var size: CGSize
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

    var commandToClosure_playing: [GameCommand: GCControllerButtonValueChangedHandler] = [:]
    var commandToClosure_start: [GameCommand: GCControllerButtonValueChangedHandler] = [:]
    var commandToClosure_alert: [GameCommand: GCControllerButtonValueChangedHandler] = [:]

    func loadSettings() -> [GameCommand: ButtonName?] {
        let defaults = UserDefaults.standard
        var result: [GameCommand: ButtonName?]?
        if let retrievedDict = defaults.dictionary(forKey: "GameCommandDict") as? [String: String] {
            result = retrievedDict.compactMapKeys { GameCommand(rawValue: $0) }
            print("LOADED SETTINGS:", result ?? "nil")
        } else {
            print("NO SETTINGS FOUND, USING DEFAULTS")
        }
        var mappings = GamePadInputManager.defaultMappings
        if let result {
            mappings = result
        }
        for (command, _) in mappings {
            commandToClosure_playing[command] = getHandlerPlayingState(command)
            commandToClosure_start[command] = getHandlerStartState()
            commandToClosure_alert[command] = getHandlerAlertState(command)
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

    @objc private func controllerDidConnect() {
        print(#function)
        for controller in GCController.controllers() {
            print(controller.vendorName ?? "Unknown Vendor")
            print(controller.productCategory)
            //Check to see whether it is an extended Game Controller (Such as a Nimbus)
            if let pad = controller.extendedGamepad {
                game.usingGamePad()
                setupOnPressed(pad: pad, dictionary: commandToClosure_playing)
                break
            }
        }
    }
    
    func onGameStateChange(state: GameState) {
        switch state {
            case .start:
                for controller in GCController.controllers() {
                    if let pad = controller.extendedGamepad {
                        setupOnPressed(pad: pad, dictionary: commandToClosure_start)
                    }
                }
            case .playing:
                for controller in GCController.controllers() {
                    if let pad = controller.extendedGamepad {
                        setupOnPressed(pad: pad, dictionary: commandToClosure_playing)
                    }
                }
//            case .alert:
//                for controller in GCController.controllers() {
//                    if let pad = controller.extendedGamepad {
//                        setupOnPressed(pad: pad, dictionary: commandToClosure_alert)
//                    }
//                }
            default: break
        }
    }

    func setupOnPressed(pad: GCExtendedGamepad, dictionary: [GameCommand: GCControllerButtonValueChangedHandler]) {
        pad.buttonA.pressedChangedHandler = { [unowned self] button, value, pressed in
            print(self, button, value, pressed)
        }
        pad.buttonB.pressedChangedHandler = { [unowned self] button, value, pressed in
            print(self, button, value, pressed)
        }
        pad.buttonX.pressedChangedHandler = { [unowned self] button, value, pressed in
            print(self, button, value, pressed)
        }
        pad.buttonY.pressedChangedHandler = { [unowned self] button, value, pressed in
            print(self, button, value, pressed)
        }
        pad.leftShoulder.pressedChangedHandler = { [unowned self] button, value, pressed in
            print(self, button, value, pressed)
        }
        pad.rightShoulder.pressedChangedHandler = { [unowned self] button, value, pressed in
            print(self, button, value, pressed)
        }
        pad.leftTrigger.pressedChangedHandler = { [unowned self] button, value, pressed in
            print(self, button, value, pressed)
        }
        pad.rightTrigger.pressedChangedHandler = { [unowned self] button, value, pressed in
            print(self, button, value, pressed)
        }
        pad.leftThumbstick.left.pressedChangedHandler = { [unowned self] button, value, pressed in
            print(self, button, value, pressed)
        }
        pad.leftThumbstick.right.pressedChangedHandler = { [unowned self] button, value, pressed in
            print(self, button, value, pressed)
        }
        pad.leftThumbstick.up.pressedChangedHandler = { [unowned self] button, value, pressed in
            print(self, button, value, pressed)
        }
        pad.leftThumbstick.down.pressedChangedHandler = { [unowned self] button, value, pressed in
            print(self, button, value, pressed)
        }
        pad.rightThumbstick.left.pressedChangedHandler = { [unowned self] button, value, pressed in
            print(self, button, value, pressed)
        }
        pad.rightThumbstick.right.pressedChangedHandler = { [unowned self] button, value, pressed in
            print(self, button, value, pressed)
        }
        pad.rightThumbstick.up.pressedChangedHandler = { [unowned self] button, value, pressed in
            print(self, button, value, pressed)
        }
        pad.rightThumbstick.down.pressedChangedHandler = { [unowned self] button, value, pressed in
            print(self, button, value, pressed)
        }
        pad.buttonMenu.pressedChangedHandler = { [unowned self] button, value, pressed in
            print(self, button, value, pressed)
        }
        pad.dpad.up.pressedChangedHandler = { [unowned self] button, value, pressed in
            print(self, button, value, pressed)
        }
        pad.dpad.down.pressedChangedHandler = { [unowned self] button, value, pressed in
            print(self, button, value, pressed)
        }
        pad.dpad.left.pressedChangedHandler = { [unowned self] button, value, pressed in
            print(self, button, value, pressed)
        }
        pad.dpad.right.pressedChangedHandler = { [unowned self] button, value, pressed in
            print(self, button, value, pressed)
        }
        // Get real values, overwriting the above
        if let command = gameCommandFromButtonName(pad.buttonA.localizedName!) {
            pad.buttonA.pressedChangedHandler = dictionary[command]
        }
        if let command = gameCommandFromButtonName(pad.buttonB.localizedName!) {
            pad.buttonB.pressedChangedHandler = dictionary[command]
        }
        if let command = gameCommandFromButtonName(pad.buttonX.localizedName!) {
            pad.buttonX.pressedChangedHandler = dictionary[command]
        }
        if let command = gameCommandFromButtonName(pad.buttonY.localizedName!) {
            pad.buttonY.pressedChangedHandler = dictionary[command]
        }
        if let command = gameCommandFromButtonName(pad.leftShoulder.localizedName!) {
            pad.leftShoulder.pressedChangedHandler = dictionary[command]
        }
        if let command = gameCommandFromButtonName(pad.rightShoulder.localizedName!) {
            pad.rightShoulder.pressedChangedHandler = dictionary[command]
        }
        if let command = gameCommandFromButtonName(pad.leftTrigger.localizedName!) {
            pad.leftTrigger.pressedChangedHandler = dictionary[command]
        }
        if let command = gameCommandFromButtonName(pad.rightTrigger.localizedName!) {
            pad.rightTrigger.pressedChangedHandler = dictionary[command]
        }
        if let command = gameCommandFromButtonName(pad.buttonMenu.localizedName!) {
            pad.buttonMenu.pressedChangedHandler = dictionary[command]
        }
        if let command = gameCommandFromButtonName(pad.dpad.up.localizedName!) {
            pad.dpad.up.pressedChangedHandler = dictionary[command]
        }
        if let command = gameCommandFromButtonName(pad.dpad.down.localizedName!) {
            pad.dpad.down.pressedChangedHandler = dictionary[command]
        }
        if let command = gameCommandFromButtonName(pad.dpad.left.localizedName!) {
            pad.dpad.left.pressedChangedHandler = dictionary[command]
        }
        if let command = gameCommandFromButtonName(pad.dpad.right.localizedName!) {
            pad.dpad.right.pressedChangedHandler = dictionary[command]
        }
        if let command = gameCommandFromButtonName(pad.leftThumbstick.left.localizedName!) {
            pad.leftThumbstick.left.pressedChangedHandler = dictionary[command]
        }
        if let command = gameCommandFromButtonName(pad.leftThumbstick.right.localizedName!) {
            pad.leftThumbstick.right.pressedChangedHandler = dictionary[command]
        }
        if let command = gameCommandFromButtonName(pad.leftThumbstick.up.localizedName!) {
            pad.leftThumbstick.up.pressedChangedHandler = dictionary[command]
        }
        if let command = gameCommandFromButtonName(pad.leftThumbstick.down.localizedName!) {
            pad.leftThumbstick.down.pressedChangedHandler = dictionary[command]
        }
        if let command = gameCommandFromButtonName(pad.rightThumbstick.left.localizedName!) {
            pad.rightThumbstick.left.pressedChangedHandler = dictionary[command]
        }
        if let command = gameCommandFromButtonName(pad.rightThumbstick.right.localizedName!) {
            pad.rightThumbstick.right.pressedChangedHandler = dictionary[command]
        }
        if let command = gameCommandFromButtonName(pad.rightThumbstick.up.localizedName!) {
            pad.rightThumbstick.up.pressedChangedHandler = dictionary[command]
        }
        if let command = gameCommandFromButtonName(pad.rightThumbstick.down.localizedName!) {
            pad.rightThumbstick.down.pressedChangedHandler = dictionary[command]
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

    let leftThumbstickButtons = ["Left Thumbstick (Left)", "Left Thumbstick (Right)", "Left Thumbstick (Up)", "Left Thumbstick (Down)"]
    let rightThumbstickButtons = ["Right Thumbstick (Left)", "Right Thumbstick (Right)", "Right Thumbstick (Up)", "Right Thumbstick (Down)"]
    let dpadButtons = ["Direction Pad (Left)", "Direction Pad (Right)", "Direction Pad (Up)", "Direction Pad (Down)"]
    
    private func getHandlerStartState() -> GCControllerButtonValueChangedHandler {
        { [weak self] (_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) -> Void in
            self?.game.engine.gameStateEntity.add(component: ChangeGameStateComponent(from: .start, to: .playing))
        }
    }

    private func getHandlerAlertState(_ command: GameCommand) -> GCControllerButtonValueChangedHandler {
        if game.alertPresenter.isAlertPresented {
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
            game.engine.gameStateEntity.add(component: ChangeGameStateComponent(from: .start, to: .playing))
        }
    }
}
