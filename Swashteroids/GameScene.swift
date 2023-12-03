import SpriteKit
import CoreGraphics
import AVFoundation
import Swash
import CoreMotion

final class GameScene: SKScene {
	var game: Asteroids!
	var motionManager: CMMotionManager?
	var orientation = 1.0

	override func didMove(to view: SKView) {
		super.didMove(to: view)
		backgroundColor = .background
		NotificationCenter.default.addObserver(self, 
											   selector: #selector(orientationChanged),
											   name: UIDevice.orientationDidChangeNotification, object: nil)
		orientation = UIDevice.current.orientation == .landscapeRight ? -1.0 : 1.0
		game.start()
	}

	@objc func orientationChanged(_ notification: Notification) {
		print(#function, UIDevice.current.orientation, notification)
		orientation = UIDevice.current.orientation == .landscapeRight ? -1.0 : 1.0
	}

	override func update(_ currentTime: TimeInterval) {
		game.dispatchTick()

		guard let data = motionManager?.accelerometerData else { return }

		switch data.acceleration.y*orientation {
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

	//MARK:- TOUCHES -------------------------

	var showHideButtons: UITouch?
	var flipTouched: UITouch?
	var hyperSpaceTouched: UITouch?
	var leftTouched: UITouch?
	var rightTouched: UITouch?
	var triggerTouched: UITouch?
	var thrustTouched: UITouch?
	let generator = UIImpactFeedbackGenerator(style: .heavy)

	func do_hyperspace() {
		childNode(withName: InputName.hyperSpaceButton)?.alpha = 0.6

		//HACK I should incorporate this into a system
		let colorize = SKAction.colorize(with: .yellow, colorBlendFactor: 1.0, duration: 0.25)
		let wait = SKAction.wait(forDuration: 0.5)
		let uncolorize = SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.25)
		let sequence = SKAction.sequence([colorize, wait, uncolorize])
		if let ship = childNode(withName: "ship") {
			let emitter = SKEmitterNode(fileNamed: "hyperspace.sks")!
			ship.addChild(emitter)
			ship.run(sequence) {
				emitter.removeFromParent()
			}
		}

		game.input.hyperSpaceIsDown = true
		game.ship?.add(component: HyperSpaceComponent(x: Double(Int.random(in: 0...Int(size.width))),
													  y: Double(Int.random(in: 0...Int(size.height)))))
	}

	//HACK I should incorporate these do_ undo_ into a system
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

	func do_left(_ amount: Double = 0.35) {
		childNode(withName: InputName.leftButton)?.alpha = 0.6
		game.input.leftIsDown = (true, amount)
	}

	func do_right(_ amount: Double = -0.35) {
		childNode(withName: InputName.rightButton)?.alpha = 0.6
		game.input.rightIsDown = (true, amount)
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
		game.input.leftIsDown = (false, 0.0)
	}

	func undo_right() {
		childNode(withName: InputName.leftButton)?.alpha = 0.2
		game.input.rightIsDown = (false, 0.0)
	}

	func do_showHideButtons(action: String) {
		let playSound = SKAction.playSoundFileNamed("toggle.wav", waitForCompletion: false)
		run(playSound)
		if let sprite = childNode(withName: "//showHideButtonsOn") as? SKSpriteNode {
			sprite.texture = SKTexture(imageNamed: "showHideButtonsOff")
			sprite.name = "showHideButtonsOff"
		} else if let sprite = childNode(withName: "//showHideButtonsOff") as? SKSpriteNode {
			sprite.texture = SKTexture(imageNamed: "showHideButtonsOn")
			sprite.name = "showHideButtonsOn"
		}
		switch action {
			case "showButtons":
				motionManager = nil
				game.creator.createButtons()
				
			case "hideButtons":
				motionManager = CMMotionManager()
				motionManager?.startAccelerometerUpdates()
				game.creator.removeButtons()
			default:
				break
		}
	}

	func touchDown(atPoint pos: CGPoint, touch: UITouch) {
		let nodeTouched = atPoint(pos) == self ? nil : atPoint(pos)

		if let _ = game.wait {
			if let nodeTouched, nodeTouched.name == "nobuttons" {
				game.input.noButtonsIsDown = true
			} else if let nodeTouched, nodeTouched.name == "buttons" {
				game.input.buttonsIsDown = true
			} else if game.input.noButtonsIsDown {
				do_showHideButtons(action: "hideButtons")
			} else if game.input.buttonsIsDown {
				do_showHideButtons(action: "showButtons")
			}
			game.input.tapped = true
			return
		}
		if let _ = game.gameOver {
			game.input.tapped = true
			generator.impactOccurred()
			return
		}
		
		guard let _ = game?.ship?.has(componentClassName: InputComponent.name) else { return }
		

		if let _ = motionManager {
			if let nodeTouched, nodeTouched.name == "showHideButtonsOff" {
				do_showHideButtons(action: "showButtons")
				return
			}
			if pos.x > size.width/2 {
				if pos.y < size.height/2 {
					do_fire()
				} else {
					do_flip()
				}
				generator.impactOccurred()
			} else {
				if pos.y < size.height/2 {
					do_thrust()
				} else {
					do_hyperspace()
				}
				generator.impactOccurred()
			}
			return			
		}
		
		guard let nodeTouched else { return }
		
		if nodeTouched.name == "showHideButtonsOn" {
			do_showHideButtons(action: "hideButtons")
			return
		}

		if nodeTouched.name == InputName.hyperSpaceButton {
			hyperSpaceTouched = touch
			do_hyperspace()
			generator.impactOccurred()
		}
		if nodeTouched.name == InputName.flipButton {
			flipTouched = touch
			do_flip()
			generator.impactOccurred()
		}
		if nodeTouched.name == InputName.fireButton {
			triggerTouched = touch
			do_fire()
			generator.impactOccurred()
		}
		if nodeTouched.name == InputName.thrustButton {
			thrustTouched = touch
			do_thrust()
			generator.impactOccurred()
		}
		// either or
		if nodeTouched.name == InputName.leftButton {
			leftTouched = touch
			do_left()
			generator.impactOccurred()
		} else if nodeTouched.name == InputName.rightButton {
			rightTouched = touch
			do_right()
			generator.impactOccurred()
		}
	}

	func touchMoved(toPoint pos: CGPoint, touch: UITouch) {
		if let _ = motionManager {
			if pos.x > size.width/2 {
				if pos.y < size.height/2 {
					undo_flip()
				} else {
					undo_fire()
				}
			} else {
				if pos.y < size.height/2 {
					undo_thrust()
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
				game.input.leftIsDown = (false, 0.0)
				game.input.rightIsDown = (false, 0.0)
			default:
				break
		}
	}

	func touchUp(atPoint pos: CGPoint, touch: UITouch) {
		guard let _ = game?.ship?.has(componentClassName: InputComponent.name)
		else { return }

		if let _ = motionManager {
			if pos.x > size.width/2 {
				if pos.y < size.height/2 {
					undo_fire()
				} else {
					undo_flip()
				}
			} else {
				if pos.y < size.height/2 {
					undo_thrust()
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
				game.input.leftIsDown = (false, 0.0)
				game.input.rightIsDown = (false, 0.0)
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
