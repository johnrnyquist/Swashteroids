//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import SpriteKit
import Swash
import GameController

extension GameScene: SoundPlaying {}

class GameScene: SKScene {
    deinit {
        removeAllActions()
        removeFromParent()
        removeAllChildren()
        NotificationCenter.default.removeObserver(self)
    }

    static var sound = SKAudioNode(fileNamed: SoundFileNames.thrust.rawValue) //HACK HACK HACK
    weak var touchDelegate: TouchDelegate?
    var previousTime = 0.0
//    var cameraNode: SKCameraNode!
    override func didMove(to view: SKView) {
        print(#function)
        super.didMove(to: view)
        setUpControllerObservers()
        //HACK to get around the SpriteKit bug where repeated sounds have a popping noise
        GameScene.sound.run(SKAction.changeVolume(to: 0, duration: 0))
        let addAudioNodeAction = SKAction.run { [weak self] in
            GameScene.sound.removeFromParent()
            self?.addChild(GameScene.sound)
        }
        run(addAudioNodeAction)
        //END_HACK
        backgroundColor = .background
//        cameraNode = SKCameraNode()
//        camera = cameraNode
//        cameraNode.setScale(1.0)
//        cameraNode.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
//        addChild(cameraNode)
    }

    //MARK:- TOUCHES -------------------------
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDelegate?.touchesBegan(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDelegate?.touchesEnded(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDelegate?.touchesMoved(touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDelegate?.touchesCancelled(touches, with: event)
    }

    override var isUserInteractionEnabled: Bool {
        get { true }
        set {}
    }
    //MARK:- GAME CONTROLLER -------------------------
    private func setUpControllerObservers() {
        print(#function)
        #if targetEnvironment(simulator)
        print("Game Controller not available on the simulator")
        #else
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
        #endif
    }

    @objc private func connectControllers() {
        print(#function)
        for controller in GCController.controllers() {
            print(controller.vendorName ?? "Unknown Vendor")
            //Check to see whether it is an extended Game Controller (Such as a Nimbus)
            if controller.extendedGamepad != nil,
               let game = delegate as? Swashteroids {
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
        let game = (delegate as! Swashteroids)
        game.engine.appStateEntity.remove(componentClass: GameControllerComponent.self)
        game.usingScreenControls()
    }

    private func setupControllerControls(controller: GCController) {
        print(#function)
        controller.extendedGamepad?.valueChangedHandler = { [weak self] (pad: GCExtendedGamepad, element: GCControllerElement) in
            self?.controllerInputDetected(pad: pad, element: element, index: controller.playerIndex.rawValue)
        }
    }

    var timeSinceFired = 0.0
    var timeSinceFlip = 0.0
    var timeSinceHyperspace = 0.0
    var game: Swashteroids { (delegate as! Swashteroids) }

    private func controllerInputDetected(pad: GCExtendedGamepad, element: GCControllerElement, index: Int) {
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

enum GameControllerInput {
    /*
Digital Elements:  
    Button A
    Button B
    Button Menu
    Button Options
    Button X
    Button Y
    Direction Pad
    Left Shoulder
    Right Shoulder
    Left Thumbstick Button
    Right Thumbstick Button
     
Analog Elements:  
    Left Thumbstick (x and y)
    Right Thumbstick (x and y)
    Left Trigger
    Right Trigger
     */
    /*
Analog:
    Element: Button A (value: 0.000, pressed: 0)
    Element: Button B (value: 1.000, pressed: 1)
    Element: Button Menu (value: 1.000, pressed: 1)
    Element: Button Options (value: 1.000, pressed: 1)
    Element: Button X (value: 0.000, pressed: 0)
    Element: Button Y (value: 0.000, pressed: 0)
    Element: Direction Pad (x: +1.000, y: +0.000)
    Element: Direction Pad (x: -0.000, y: +0.000)
    Element: Direction Pad (x: -0.000, y: +1.000)
    Element: Direction Pad (x: -0.000, y: -1.000)
    Element: Direction Pad (x: -1.000, y: +0.000)
    Element: Left Shoulder (value: 0.000, pressed: 0)
    Element: Right Shoulder (value: 0.000, pressed: 0)
    Element: Right Thumbstick Button (value: 0.000, pressed: 0)
     
Digital:
    Element: Left Thumbstick (x: +0.001, y: +0.009)
    Element: Left Trigger (value: 0.000, pressed: 0)
    Element: Right Thumbstick (x: +0.002, y: -0.008)
    Element: Right Trigger (value: 0.000, pressed: 0)
     */
    case buttonA
    case buttonB
    case buttonMenu
    case buttonX
    case buttonY
    case dpadDown
    case dpadLeft
    case dpadRight
    case dpadUp
    case leftShoulder
    case leftThumbstickButtonPressed
    case leftThumbstickDown
    case leftThumbstickLeft
    case leftThumbstickRight
    case leftThumbstickUp
    case leftTrigger
    case rightShoulder
    case rightThumbstickButtonPressed
    case rightThumbstickDown
    case rightThumbstickLeft
    case rightThumbstickRight
    case rightThumbstickUp
    case rightTrigger
    var description: String {
        switch self {
            case .buttonA: return "buttonA"
            case .buttonB: return "buttonB"
            case .buttonMenu: return "buttonMenu"
            case .buttonX: return "buttonX"
            case .buttonY: return "buttonY"
            case .dpadDown: return "dpadDown"
            case .dpadLeft: return "dpadLeft"
            case .dpadRight: return "dpadRight"
            case .dpadUp: return "dpadUp"
            case .leftShoulder: return "leftShoulder"
            case .leftThumbstickButtonPressed: return "leftThumbstickButtonPressed"
            case .leftThumbstickDown: return "leftThumbstickDown"
            case .leftThumbstickLeft: return "leftThumbstickLeft"
            case .leftThumbstickRight: return "leftThumbstickRight"
            case .leftThumbstickUp: return "leftThumbstickUp"
            case .leftTrigger: return "leftTrigger"
            case .rightShoulder: return "rightShoulder"
            case .rightThumbstickButtonPressed: return "rightThumbstickButtonPressed"
            case .rightThumbstickDown: return "rightThumbstickDown"
            case .rightThumbstickLeft: return "rightThumbstickLeft"
            case .rightThumbstickRight: return "rightThumbstickRight"
            case .rightThumbstickUp: return "rightThumbstickUp"
            case .rightTrigger: return "rightTrigger"
        }
    }
}

class GameControllerComponent: Component {
    var commands: [GameControllerInput] = []

    func add(command: GameControllerInput) {
        commands.append(command)
    }

    func remove(command: GameControllerInput) {
        if let index = commands.firstIndex(of: command) {
            commands.remove(at: index)
        }
    }

    func has(command: GameControllerInput) -> Bool {
        commands.contains(command)
    }

    func clear() {
        commands.removeAll()
    }
}

