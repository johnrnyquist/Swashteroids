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
    @Published var gameCommandToElementName: [GameCommand: String?] = GamePadManager.defaultMappings
    @Published var lastElementPressed: String?
    static let defaultMappings: [GameCommand: String?] = [
        // always available in game
        .left: "Left Thumbstick (Left)",
        .right: "Left Thumbstick (Right)",
        .thrust: "Right Thumbstick (Up)",
        .flip: "L1 Button",
        .pause: "Menu Button",
        // sometimes available in game. power ups
        .fire: "R2 Button",
        .hyperspace: "R1 Button",
        // when alert is up
        .home: "X Button",
        .resume: "B Button",
        .settings: "Y Button",
        // start and info screens
        .continue: "A Button",
    ]
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
        gameCommandToElementName = loadSettings()
    }

    func findKey(forValue value: String, in dictionary: [GameCommand: String?]) -> GameCommand? {
        for (key, val) in dictionary {
            if val == value {
                return key
            }
        }
        return nil
    }

    func loadSettings() -> [GameCommand: String?] {
        let defaults = UserDefaults.standard
        var result: [GameCommand: String?]?
        if let retrievedDict = defaults.dictionary(forKey: "GameCommandDict") as? [String: String] {
            result = retrievedDict.compactMapKeys { GameCommand(rawValue: $0) }
        }
        return result ?? GamePadManager.defaultMappings
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

    func fire() {
        if timeSinceFired > 0.2 {
            timeSinceFired = 0.0
            game.engine.ship?.add(component: FireDownComponent.shared)
        }
    }

    func thrust() {
        game.engine.ship?.add(component: ApplyThrustComponent.shared)
        game.engine.ship?[WarpDriveComponent.self]?.isThrusting = true
        game.engine.ship?[RepeatingAudioComponent.self]?.state = .shouldBegin
    }

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

    func thrust_off() {
        game.engine.ship?.remove(componentClass: ApplyThrustComponent.self)
        game.engine.ship?[WarpDriveComponent.self]?.isThrusting = false
        game.engine.ship?[RepeatingAudioComponent.self]?.state = .shouldStop
    }

    private func execute(_ command: GameCommand) {
        print(#function, command)
        let deltaTime = game.currentTime - previousTime
        previousTime = game.currentTime
        timeSinceFired += deltaTime
        timeSinceFlip += deltaTime
        timeSinceHyperspace += deltaTime
        switch command {
            case .fire: fire()
            case .thrust: thrust()
            case .hyperspace: hyperSpace()
            case .left: turn_left()
            case .right: turn_right()
            case .pause: break
            case .flip: flip()
            case .home: break
            case .settings: break
            case .resume: break
            case .continue: break
            case .buttons: break
            case .noButtons: break
        }
    }

    func resolveInput(pad: GCExtendedGamepad, element: GCControllerElement) -> [GCControllerButtonInput] {
        print("element", element.localizedName!)
        var button: GCControllerButtonInput? = element as? GCControllerButtonInput
        var buttons: [GCControllerButtonInput?] = []
        if let button { // element is a button
            if button.isPressed {
                buttons.append(button)
            }
        } else if let dpad = element as? GCControllerDirectionPad { // element is a dpad
            switch dpad { // what kind of dpad
                case pad.dpad: // these are exclusive positions
                    if pad.dpad.left.isPressed {
                        button = pad.dpad.left
                        buttons.append(button)
                    } else if pad.dpad.right.isPressed {
                        button = pad.dpad.right
                        buttons.append(button)
                    } else if pad.dpad.up.isPressed {
                        button = pad.dpad.up
                        buttons.append(button)
                    } else if pad.dpad.down.isPressed {
                        button = pad.dpad.down
                        buttons.append(button)
                    }
                case pad.leftThumbstick: // these are non-exclusive positions
                    if pad.leftThumbstick.left.isPressed {
                        button = pad.leftThumbstick.left
                        buttons.append(button)
                    }
                    if pad.leftThumbstick.right.isPressed {
                        button = pad.leftThumbstick.right
                        buttons.append(button)
                    }
                    if pad.leftThumbstick.up.isPressed {
                        button = pad.leftThumbstick.up
                        buttons.append(button)
                    }
                    if pad.leftThumbstick.down.isPressed {
                        button = pad.leftThumbstick.down
                        buttons.append(button)
                    }
                case pad.rightThumbstick: // these are non-exclusive positions
                    if pad.rightThumbstick.left.isPressed {
                        button = pad.rightThumbstick.left
                        buttons.append(button)
                    }
                    if pad.rightThumbstick.right.isPressed {
                        button = pad.rightThumbstick.right
                        buttons.append(button)
                    }
                    if pad.rightThumbstick.up.isPressed {
                        button = pad.rightThumbstick.up
                        buttons.append(button)
                    }
                    if pad.rightThumbstick.down.isPressed {
                        button = pad.rightThumbstick.down
                        buttons.append(button)
                    }
                default:
                    break
            }
        }
        return buttons.compactMap { $0 }
    }

    private func controllerInputDetected(pad: GCExtendedGamepad, element: GCControllerElement) {
        let buttons = resolveInput(pad: pad, element: element)
        lastElementPressed = buttons.last?.localizedName
//        guard let elementName = lastElementPressed,
//              let command = findKey(forValue: elementName, in: gameCommandToElementName),
//              mode == .game
//        else {
//            return
//        }
//        for button in buttons {
//            if let elementName = button.localizedName,
//               let command = findKey(forValue: elementName, in: gameCommandToElementName) {
//                execute(command)
//            }
//        }
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
        let deltaTime = game.currentTime - previousTime
        previousTime = game.currentTime
        timeSinceFired += deltaTime
        timeSinceFlip += deltaTime
        timeSinceHyperspace += deltaTime
        // HYPERSPACE
        if pad.rightShoulder.isPressed {
            hyperSpace()
        }
        // FLIP
        if pad.leftShoulder.isPressed {
            flip()
        }
        // FIRE
        if pad.rightTrigger.isPressed {
            fire()
        }
        // TURN LEFT
        if pad.leftThumbstick.left.isPressed  {
            turn_left()
        } else {
            turn_left_off()
        }
        // TURN RIGHT
        if pad.leftThumbstick.right.isPressed  {
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
    let elementNameToSymbolName: [ElementName: ElementSymbolName] = [
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



