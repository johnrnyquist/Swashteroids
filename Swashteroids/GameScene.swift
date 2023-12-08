import SpriteKit

import CoreMotion

final class GameScene: SKScene {
    var game: Swashteroids!
    var motionManager: CMMotionManager?
    var orientation = 1.0

    override func didMove(to view: SKView) {
        print(self, #function)
        super.didMove(to: view)
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
        game.dispatchTick()
        guard let data = motionManager?.accelerometerData else { return }
        switch data.acceleration.y * orientation {
            case let y where y > 0.05:
				undo_right()
				do_left(data.acceleration.y*orientation)
            case let y where y < -0.05:
				undo_left()
				do_right(data.acceleration.y*orientation)
            case -0.05...0.05:
				undo_left()
				undo_right()
            default:
                break
        }
    }

    func do_left(_ amount: Double = 0.35) {
        game.inputComponent.leftIsDown = (true, amount)
    }

    func do_right(_ amount: Double = -0.35) {
        game.inputComponent.rightIsDown = (true, amount)
    }
    func undo_left() {
        game.inputComponent.leftIsDown = (false, 0.0)
    }

    func undo_right() {
        game.inputComponent.rightIsDown = (false, 0.0)
    }

    //MARK:- TOUCHES -------------------------

    func touchDown(atPoint location: CGPoint, touch: UITouch) {
        game.inputComponent.handleTouchDowns(nodes: nodes(at: location), touch: touch, location: location)
    }

    func touchUp(atPoint location: CGPoint, touch: UITouch) {
        game.inputComponent.handleTouchUps(nodes: nodes(at: location), touch: touch, location: location)
    }

    func touchMoved(toPoint location: CGPoint, touch: UITouch) {
        let p = touch.location(in: self) - touch.previousLocation(in: self)
        let d = max(abs(p.x), abs(p.y))
        guard d > 1 else { return }
        game.inputComponent.handleTouchMoveds(nodes: nodes(at: location), touch: touch, location: location)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        for touch in touches {
            touchDown(atPoint: touch.location(in: self), touch: touch)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchUp(atPoint: touch.location(in: self), touch: touch)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchMoved(toPoint: touch.location(in: self), touch: touch)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(self, #function)
        for touch in touches {
            touchUp(atPoint: touch.location(in: self), touch: touch)
        }
    }

    override var isUserInteractionEnabled: Bool {
        get { true }
        set {}
    }
}
