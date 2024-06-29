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

class GameControllerManager: NSObject {
    @Published var lastButtonPressed: String?

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
        setUpControllerObservers()
    }

    private func setUpControllerObservers() {
        print(#function)
        NotificationCenter.default
                          .addObserver(self,
                                       selector: #selector(self.connectControllers),
                                       name: NSNotification.Name.GCControllerDidConnect,
                                       object: nil)
        NotificationCenter.default
                          .addObserver(self,
                                       selector: #selector(self.controllerDisconnected),
                                       name: NSNotification.Name.GCControllerDidDisconnect,
                                       object: nil)
    }

    @objc private func connectControllers() {
        print(#function)
        for controller in GCController.controllers() {
            print(controller.vendorName ?? "Unknown Vendor")
            //Check to see whether it is an extended Game Controller (Such as a Nimbus)
            if controller.extendedGamepad != nil {
                game.engine.appStateEntity.add(component: GameControllerComponent())
                game.usingGameController()
                setupControllerControls(controller: controller)
                if game.engine.appStateComponent.swashteroidsState == .infoButtons ||
                   game.engine.appStateComponent.swashteroidsState == .infoNoButtons {
                    (game.alertPresenter as? GameViewController)?.startNewGame() //HACK
                }
                break
            }
        }
    }

    @objc private func controllerDisconnected() {
        print(#function)
        game.engine.appStateEntity.remove(componentClass: GameControllerComponent.self)
        game.usingScreenControls()
    }

    func getAllElements(gamepad: GCExtendedGamepad) -> [String: Any] {
        var elements: [String: Any] = [:]
        elements["buttonA"] = gamepad.buttonA
        elements["buttonB"] = gamepad.buttonB
        elements["buttonX"] = gamepad.buttonX
        elements["buttonY"] = gamepad.buttonY
        elements["dpad"] = gamepad.dpad
        elements["leftShoulder"] = gamepad.leftShoulder
        elements["rightShoulder"] = gamepad.rightShoulder
        elements["leftThumbstick"] = gamepad.leftThumbstick
        elements["rightThumbstick"] = gamepad.rightThumbstick
        elements["leftTrigger"] = gamepad.leftTrigger
        elements["rightTrigger"] = gamepad.rightTrigger
        elements["buttonHome"] = gamepad.buttonHome
        elements["buttonMenu"] = gamepad.buttonMenu
        return elements
    }

    private func setupControllerControls(controller: GCController) {
        print(#function)
        controller
                .extendedGamepad?
                .valueChangedHandler = { [weak self] (pad: GCExtendedGamepad, element: GCControllerElement) in
            self?.controllerInputDetected(pad: pad, element: element, index: controller.playerIndex.rawValue)
        }
    }

    private func controllerInputDetected(pad: GCExtendedGamepad, element: GCControllerElement, index: Int) {
        let elements = getAllElements(gamepad: pad)
        for (elementName, elementValue) in elements {
            if let buttonInput = elementValue as? GCControllerButtonInput, buttonInput.isPressed {
                lastButtonPressed = elementName // Set the name of the pressed button
                if let mappedFunctionality = buttonMappings[elementName] {
                    executeFunctionality(mappedFunctionality)
                }
            }
        }
        printControllerInfo(element: element, index: index)
        let gameControllerComponent = GameControllerComponent()
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
        print(gameControllerComponent.commands)
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
        if timeSinceHyperspace > 0.5 && (pad.rightShoulder.isPressed && pad.rightShoulder.value == 1.0) {
            timeSinceHyperspace = 0.0
            game.engine.ship?.add(component: DoHyperspaceJumpComponent(size: size))
        }
        // FLIP
        if timeSinceFlip > 0.2 && (pad.leftShoulder.isPressed && pad.leftShoulder.value == 1.0) {
            timeSinceFlip = 0.0
            game.engine.ship?.add(component: FlipComponent.shared)
        }
        // FIRE
        if timeSinceFired > 0.2 {
            if pad.rightTrigger.isPressed,
               pad.rightTrigger.value == 1.0 {
                timeSinceFired = 0.0
                game.engine.ship?.add(component: FireDownComponent.shared)
            }
        }
        // TURN LEFT
        if pad.leftThumbstick.left.isPressed || pad.dpad.left.isPressed {
            game.engine.ship?.add(component: LeftComponent.shared)
        } else {
            game.engine.ship?.remove(componentClass: LeftComponent.self)
        }
        // TURN RIGHT
        if pad.leftThumbstick.right.isPressed || pad.dpad.right.isPressed {
            game.engine.ship?.add(component: RightComponent.shared)
        } else {
            game.engine.ship?.remove(componentClass: RightComponent.self)
        }
        // THRUST
        if pad.rightThumbstick.up.isPressed {
            game.engine.ship?.add(component: ApplyThrustComponent.shared)
            game.engine.ship?[WarpDriveComponent.self]?.isThrusting = true
            game.engine.ship?[RepeatingAudioComponent.self]?.state = .shouldBegin
        } else {
            game.engine.ship?.remove(componentClass: ApplyThrustComponent.self)
            game.engine.ship?[WarpDriveComponent.self]?.isThrusting = false
            game.engine.ship?[RepeatingAudioComponent.self]?.state = .shouldStop
        }
    }

    private func printControllerInfo(element: GCControllerElement, index: Int) {
        print("----")
        print("Controller:              \(index), Element: \(element)")
        print("localizedName:           \(element.localizedName!)")
        print("unmappedLocalizedName:   \(element.unmappedLocalizedName!)")
        print("sfSymbolsName:           \(element.sfSymbolsName!)")
        print("unmappedSfSymbolsName:   \(element.unmappedSfSymbolsName!)")
        print("aliases:                 \(element.aliases)")
        print("isAnalog:                \(element.isAnalog)")
        print("----")
    }
}

class GameControllerComponent: Component {
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

