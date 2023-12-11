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
import CoreMotion

final class GameScene: SKScene {
    private var orientation = 1.0
    var game: Swashteroids! // set externally before didMove(to:)
    var motionManager: CMMotionManager?
	var inputComponent = InputComponent.shared
    static var sound = SKAudioNode(fileNamed: "thrust.wav") //HACK HACK HACK
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
//		let border = SKSpriteNode(imageNamed: "border")
//		border.anchorPoint = CGPoint(x: 0, y: 0)
//		border.position = CGPoint(x: 0, y: 0)
//		addChild(border)

        //HACK to get around the SpriteKit bug where repeated sounds have a popping noise
        GameScene.sound.run(SKAction.changeVolume(to: 0, duration: 0))
        let addAudioNodeAction = SKAction.run { [unowned self] in
            addChild(GameScene.sound)
        }
        run(addAudioNodeAction)
        //END_HACK
        
        backgroundColor = .background
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(orientationChanged),
                                               name: UIDevice.orientationDidChangeNotification, object: nil)
        orientation = UIDevice.current.orientation == .landscapeRight ? -1.0 : 1.0
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
        game.start()
    }

    @objc func orientationChanged(_ notification: Notification) {
        print(#function, UIDevice.current.orientation, notification)
        orientation = UIDevice.current.orientation == .landscapeRight ? -1.0 : 1.0
    }

    override func update(_ currentTime: TimeInterval) {
        game.dispatchTick() // This drives the game
        guard let data = motionManager?.accelerometerData else { return }
        switch data.acceleration.y * orientation {
            case let y where y > 0.05:
                undo_right()
                do_left(data.acceleration.y * orientation)
            case let y where y < -0.05:
                undo_left()
                do_right(data.acceleration.y * orientation)
            case -0.05...0.05:
                undo_left()
                undo_right()
            default:
                break
        }
    }

    func do_left(_ amount: Double = 0.35) {
        inputComponent.leftIsDown = (true, amount)
    }

    func undo_left() {
        inputComponent.leftIsDown = (false, 0.0)
    }

    func do_right(_ amount: Double = -0.35) {
        inputComponent.rightIsDown = (true, amount)
    }

    func undo_right() {
        inputComponent.rightIsDown = (false, 0.0)
    }

    //MARK:- TOUCHES -------------------------
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        for touch in touches {
            let location = touch.location(in: self)
            inputComponent.handleTouchDowns(nodes: nodes(at: location), touch: touch, location: location)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            inputComponent.handleTouchUps(nodes: nodes(at: location), touch: touch, location: location)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let p = touch.location(in: self) - touch.previousLocation(in: self)
            let d = max(abs(p.x), abs(p.y))
            guard d > 1 else { return }
            inputComponent.handleTouchMoveds(nodes: nodes(at: location), touch: touch, location: location)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            inputComponent.handleTouchUps(nodes: nodes(at: location), touch: touch, location: location)
        }
    }

    override var isUserInteractionEnabled: Bool {
        get { true }
        set {}
    }
}
