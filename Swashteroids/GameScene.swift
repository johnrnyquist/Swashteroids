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
import GameController

extension GameScene: SoundPlaying {}

extension GameScene: Container {}

final class GameScene: SKScene {
    static var sound = SKAudioNode(fileNamed: SoundFileNames.thrust.rawValue) //HACK HACK HACK
    var touchDelegate: TouchDelegate?
    var previousTime = 0.0
//    var cameraNode: SKCameraNode!
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setUpControllerObservers()
        //HACK to get around the SpriteKit bug where repeated sounds have a popping noise
        GameScene.sound.run(SKAction.changeVolume(to: 0, duration: 0))
        let addAudioNodeAction = SKAction.run { [unowned self] in
            GameScene.sound.removeFromParent()
            addChild(GameScene.sound)
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

    @objc func connectControllers() {
        print(#function)
        for controller in GCController.controllers() {
            print(controller.vendorName)
            //Check to see whether it is an extended Game Controller (Such as a Nimbus)
            if controller.extendedGamepad != nil {
                print("Extended Gamepad")
                setupControllerControls(controller: controller)
            }
        }
    }

    func setupControllerControls(controller: GCController) {
        //Function that check the controller when anything is moved or pressed on it
        controller.extendedGamepad?.valueChangedHandler = { (pad: GCExtendedGamepad, element: GCControllerElement) in
            // Add movement in here for sprites of the controllers
            self.controllerInputDetected(pad: pad, element: element, index: controller.playerIndex.rawValue)
        }
    }

    var timeSinceFired = 0.0
    var timeSinceFlip = 0.0

    func controllerInputDetected(pad: GCExtendedGamepad, element: GCControllerElement, index: Int) {
        print("Controller: \(index), Element: \(element)")
        let game = (delegate as! Swashteroids)
        let deltaTime = game.currentTime - previousTime
        previousTime = game.currentTime
        timeSinceFired += deltaTime
        timeSinceFlip += deltaTime
        // HYPERSPACE
        if pad.buttonA.isPressed {
            game.engine.ship?.add(component: DoHyperspaceJumpComponent(size: size, randomness: game.randomness))
        }
        // FLIP
        if pad.dpad.up.isPressed {
            timeSinceFlip = 0
            game.engine.ship?.add(component: FlipComponent.shared)
        }
        // FIRE
        if timeSinceFired > 0.1 {
            if pad.rightTrigger.isPressed, pad.rightTrigger.value == 1.0  {
                timeSinceFired = 0
                game.engine.ship?.add(component: FireDownComponent.shared)
            }
        }
        // LEFT
        if pad.leftThumbstick.left.isPressed || pad.dpad.left.isPressed {
            game.engine.ship?.add(component: LeftComponent.shared)
        } else {
            game.engine.ship?.remove(componentClass: LeftComponent.self)
        }
        // RIGHT
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

    @objc func controllerDisconnected() {
        print(#function)
    }
}
