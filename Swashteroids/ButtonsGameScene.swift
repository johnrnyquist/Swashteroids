import SpriteKit
import CoreGraphics
import AVFoundation
import Swash
import CoreMotion

final class ButtonsGameScene: SKScene {
	var game: Asteroids!
	var motionManager: CMMotionManager?

	override func didMove(to view: SKView) {
		super.didMove(to: view)
		backgroundColor = .background
		game.start()
	}

	override func update(_ currentTime: TimeInterval) {
		game.dispatchTick()


		guard let data = motionManager?.accelerometerData else { return }
		switch data.acceleration.y {
			case let x where x > 0.2:
				undo_right()
				do_left()
			case let x where x < -0.2:
				undo_left()
				do_right()
			case -0.2...0.2:
				undo_left()
				undo_right()
			default:
				break
		}		
		if data.acceleration.y > 0.2 {
			undo_right()
			do_left()
		} else if data.acceleration.y < -0.2 {
			undo_left()
			do_right()
		}
		if data.acceleration.x > -0.65 { // landscape right
			do_thrust()
		} else {
			undo_thrust()
		}
	}

	//MARK:- TOUCHES -------------------------

	var flipTouched: UITouch?
	var hyperSpaceTouched: UITouch?
	var leftTouched: UITouch?
	var rightTouched: UITouch?
	var triggerTouched: UITouch?
	var thrustTouched: UITouch?
	let generator = UIImpactFeedbackGenerator(style: .heavy)

	func do_hyperspace() {
		childNode(withName: InputName.hyperSpaceButton)?.alpha = 0.6
		game.input.hyperSpaceIsDown = true
		game.ship?.add(component: HyperSpaceComponent(x: Double(Int.random(in: 0...Int(size.width))),
													  y: Double(Int.random(in: 0...Int(size.height)))))
	}

	func do_flip() {
		childNode(withName: InputName.flipButton)?.alpha = 0.6
		game.input.flipIsDown = true
	}

	func do_fire() {
		childNode(withName: InputName.fireButton)?.alpha = 0.6
		game.input.triggerIsDown = true
	}

	func do_thrust() {
			childNode(withName: InputName.thrustButton)?.alpha = 0.6
			game.input.thrustIsDown = true
	}

	func do_left() {
		childNode(withName: InputName.leftButton)?.alpha = 0.6
		game.input.leftIsDown = true
	}

	func do_right() {
		childNode(withName: InputName.rightButton)?.alpha = 0.6
		game.input.rightIsDown = true
	}

	func undo_hyperspace() {
		childNode(withName: InputName.hyperSpaceButton)?.alpha = 0.2
		game.input.hyperSpaceIsDown = false
	}

	func undo_flip() {
		childNode(withName: InputName.flipButton)?.alpha = 0.2
		game.input.flipIsDown = false
	}

	func undo_fire() {
		childNode(withName: InputName.fireButton)?.alpha = 0.2
		game.input.triggerIsDown = false
	}

	func undo_thrust() {
		if game.input.thrustIsDown == true {
			childNode(withName: InputName.thrustButton)?.alpha = 0.2
			game.input.thrustIsDown = false
		}
	}

	func undo_left() {
		childNode(withName: InputName.rightButton)?.alpha = 0.2
		game.input.leftIsDown = false
	}

	func undo_right() {
		childNode(withName: InputName.leftButton)?.alpha = 0.2
		game.input.rightIsDown = false
	}

	func touchDown(atPoint pos: CGPoint, touch: UITouch) {
		if let _ = game.wait {
			if pos.x < size.width/2 {
				// remove buttons
				game.creator.removeButtons()
				motionManager = CMMotionManager()		
				motionManager?.startAccelerometerUpdates()
			} else {
				// keep buttons
				motionManager = nil
				game.creator.createButtons()
			}
			game.input.tapped = true
			generator.impactOccurred()
			return
		}
		if let _ = game.gameOver {
			game.input.tapped = true
			generator.impactOccurred()
			return
		}
		
		guard let _ = game?.ship?.has(componentClassName: InputComponent.name) else { return }
		
		if let _ = motionManager {
			if pos.x > size.width/2 {
				game.input.triggerIsDown = true
				do_fire()
				generator.impactOccurred()
			} else {
				if pos.y < size.height/2 {
					game.input.flipIsDown = true
					do_flip()
					generator.impactOccurred()
				} else {
					do_hyperspace()
					generator.impactOccurred()
				}
			}
			return			
		}
		
		guard let nodeTouched = atPoint(pos) == self ? nil : atPoint(pos)
		else { return }
		
		if nodeTouched.name == InputName.hyperSpaceButton {
			hyperSpaceTouched = touch
			do_hyperspace()
			generator.impactOccurred()
		}
		if nodeTouched.name == InputName.flipButton {
			flipTouched = touch
			game.input.flipIsDown = true
			do_flip()
			generator.impactOccurred()
		}
		if nodeTouched.name == InputName.fireButton {
			triggerTouched = touch
			game.input.triggerIsDown = true
			do_fire()
			generator.impactOccurred()
		}
		if nodeTouched.name == InputName.thrustButton {
			thrustTouched = touch
			game.input.thrustIsDown = true
			do_thrust()
			generator.impactOccurred()
		}
		// either or
		if nodeTouched.name == InputName.leftButton {
			leftTouched = touch
			game.input.leftIsDown = true
			do_left()
			generator.impactOccurred()
		} else if nodeTouched.name == InputName.rightButton {
			rightTouched = touch
			game.input.rightIsDown = true
			do_right()
			generator.impactOccurred()
		}
	}

	func touchMoved(toPoint pos: CGPoint, touch: UITouch) {
	}

	func touchUp(atPoint pos: CGPoint, touch: UITouch) {
		guard let _ = game?.ship?.has(componentClassName: InputComponent.name)
		else { return }

		if let _ = motionManager {
			if pos.x > size.width/2 {
				undo_fire()
			} else {
				if pos.y < size.height/2 {
					undo_flip()
				} else {
					undo_hyperspace()
				}
			}
			return
		}


		switch touch {
			case hyperSpaceTouched:
				childNode(withName: InputName.hyperSpaceButton)?.alpha = 0.2
				hyperSpaceTouched = nil
				game.input.hyperSpaceIsDown = false
			case flipTouched:
				childNode(withName: InputName.flipButton)?.alpha = 0.2
				flipTouched = nil
				game.input.flipIsDown = false
			case triggerTouched:
				childNode(withName: InputName.fireButton)?.alpha = 0.2
				triggerTouched = nil
				game.input.triggerIsDown = false
			case thrustTouched:
				childNode(withName: InputName.thrustButton)?.alpha = 0.2
				thrustTouched = nil
				game.input.thrustIsDown = false
			case leftTouched, rightTouched:
				childNode(withName: InputName.leftButton)?.alpha = 0.2
				childNode(withName: InputName.rightButton)?.alpha = 0.2
				leftTouched = nil
				rightTouched = nil
				game.input.leftIsDown = false
				game.input.rightIsDown = false
			default:
				break
		}
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		for t in touches {
			touchDown(atPoint: t.location(in: self), touch: t)
		}
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches {
			touchMoved(toPoint: t.location(in: self), touch: t)
		}
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches {
			touchUp(atPoint: t.location(in: self), touch: t)
		}
	}

	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches {
			touchUp(atPoint: t.location(in: self), touch: t)
		}
	}

	override var isUserInteractionEnabled: Bool {
		get { true }
		set {}
	}
}
