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
        print("GameScene deinit")
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
    func setUpControllerObservers() {
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
        connectControllers()
    }

    @objc func connectControllers() {
        print(#function)
        for controller in GCController.controllers() {
            print(controller.vendorName ?? "Unknown Vendor")
            //Check to see whether it is an extended Game Controller (Such as a Nimbus)
            if controller.extendedGamepad != nil,
               let game = delegate as? Swashteroids {
                print("Extended Gamepad")
                game.engine.appStateEntity.add(component: GameControllerComponent())
                game.usingGameController()
                setupControllerControls(controller: controller)
                break
            }
        }
    }

    @objc func controllerDisconnected() {
        print(#function)
        let game = (delegate as! Swashteroids)
        game.engine.appStateEntity.remove(componentClass: GameControllerComponent.self)
        game.usingScreenControls()
    }

    func setupControllerControls(controller: GCController) {
        //Function that check the controller when anything is moved or pressed on it
        controller.extendedGamepad?.valueChangedHandler = { [weak self] (pad: GCExtendedGamepad, element: GCControllerElement) in
            // Add movement in here for sprites of the controllers
            self?.controllerInputDetected(pad: pad, element: element, index: controller.playerIndex.rawValue)
        }
    }

    var timeSinceFired = 0.0
    var timeSinceFlip = 0.0
    var timeSinceHyperspace = 0.0

    func controllerInputDetected(pad: GCExtendedGamepad, element: GCControllerElement, index: Int) {
        print("Controller: \(index), Element: \(element)")
        let game = (delegate as! Swashteroids)
        let gameControllerComponent = GameControllerComponent()
        
        print("appState: \(game.engine.appStateComponent.appState)")
        if game.engine.appStateComponent.appState == .start {
            if pad.buttonA.isPressed {
                gameControllerComponent.add(command: .buttonA)
                game.engine.appStateEntity.add(component: ChangeShipControlsStateComponent(to: .usingGameController))
                game.engine.appStateEntity.add(component: TransitionAppStateComponent(from: .start, to: .playing))
                return
            }
        }
        if game.engine.appStateComponent.appState == .gameOver {
            if pad.buttonY.isPressed {
                gameControllerComponent.add(command: .buttonY)
                game.engine.appStateEntity.add(component: ChangeShipControlsStateComponent(to: .usingGameController))
                game.engine.appStateEntity.add(component: TransitionAppStateComponent(from: .gameOver, to: .start))
                return
            }
            if pad.buttonA.isPressed && !game.alertPresenter.isAlertPresented {
                gameControllerComponent.add(command: .buttonA)
                game.alertPresenter.showPauseAlert()
                return
            }
            if pad.buttonX.isPressed {
                gameControllerComponent.add(command: .buttonX)
                game.alertPresenter.home()
                return
            }
            if pad.buttonB.isPressed {
                gameControllerComponent.add(command: .buttonB)
                game.alertPresenter.resume()
                return
            }
        }
        if game.engine.appStateComponent.appState == .playing {
            if !game.alertPresenter.isAlertPresented,
               pad.buttonY.isPressed {
                gameControllerComponent.add(command: .buttonY)
                game.alertPresenter.showPauseAlert()
                return
            } else if game.alertPresenter.isAlertPresented,
                      pad.buttonX.isPressed {
                gameControllerComponent.add(command: .buttonX)
                game.alertPresenter.home()
                return
            } else if game.alertPresenter.isAlertPresented,
                      pad.buttonB.isPressed {
                gameControllerComponent.add(command: .buttonB)
                game.alertPresenter.resume()
                return
            }
        }
        let deltaTime = game.currentTime - previousTime
        previousTime = game.currentTime
        timeSinceFired += deltaTime
        timeSinceFlip += deltaTime
        timeSinceHyperspace += deltaTime
        // HYPERSPACE
        if timeSinceHyperspace > 0.5 && (pad.rightShoulder.isPressed && pad.rightShoulder.value == 1.0) {
            gameControllerComponent.add(command: .rightShoulder)
            timeSinceHyperspace = 0.0
            game.engine.ship?.add(component: DoHyperspaceJumpComponent(size: size))
        }
        // FLIP
        if timeSinceFlip > 0.2 && (pad.leftShoulder.isPressed && pad.leftShoulder.value == 1.0) {
            gameControllerComponent.add(command: .leftShoulder)
            timeSinceFlip = 0.0
            game.engine.ship?.add(component: FlipComponent.shared)
        }
        // FIRE
        if timeSinceFired > 0.2 {
            if pad.rightTrigger.isPressed,
               pad.rightTrigger.value == 1.0 {
                gameControllerComponent.add(command: .rightTrigger)
                timeSinceFired = 0.0
                game.engine.ship?.add(component: FireDownComponent.shared)
            }
        }
        // TURN LEFT
        if pad.leftThumbstick.left.isPressed || pad.dpad.left.isPressed {
            gameControllerComponent.add(command: .leftThumbstickLeft) //TODO: Need to get dpad.left in another test
            game.engine.ship?.add(component: LeftComponent.shared)
        } else {
            game.engine.ship?.remove(componentClass: LeftComponent.self)
        }
        // TURN RIGHT
        if pad.leftThumbstick.right.isPressed || pad.dpad.right.isPressed {
            gameControllerComponent.add(command: .leftThumbstickRight) //TODO: Need to get dpad.right in another test
            game.engine.ship?.add(component: RightComponent.shared)
        } else {
            game.engine.ship?.remove(componentClass: RightComponent.self)
        }
        // THRUST
        if pad.rightThumbstick.up.isPressed {
            gameControllerComponent.add(command: .rightThumbstickUp)
            game.engine.ship?.add(component: ApplyThrustComponent.shared)
            game.engine.ship?[WarpDriveComponent.self]?.isThrusting = true
            game.engine.ship?[RepeatingAudioComponent.self]?.state = .shouldBegin
        } else {
            game.engine.ship?.remove(componentClass: ApplyThrustComponent.self)
            game.engine.ship?[WarpDriveComponent.self]?.isThrusting = false
            game.engine.ship?[RepeatingAudioComponent.self]?.state = .shouldStop
        }
        print(gameControllerComponent.commands)
    }
}

enum GameControllerInput {
    case rightThumbstickUp
    case rightThumbstickDown
    case rightThumbstickLeft
    case rightThumbstickRight
    case rightThumbstickButtonPressed
    case leftThumbstickUp
    case leftThumbstickDown
    case leftThumbstickLeft
    case leftThumbstickRight
    case leftThumbstickButtonPressed
    case rightTrigger
    case leftTrigger
    case rightShoulder
    case leftShoulder
    case buttonA
    case buttonB
    case buttonX
    case buttonY
    case buttonMenu
    case dpadUp
    case dpadDown
    case dpadLeft
    case dpadRight
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

