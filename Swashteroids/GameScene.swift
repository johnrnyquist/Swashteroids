import SpriteKit
import CoreGraphics
import AVFoundation
import Swash

final class GameScene: SKScene {
	var game: Asteroids!
	var keyPoll: KeyPoll! //HACK
	var ship: Entity?

	override func didMove(to view: SKView) {
		super.didMove(to: view)
		game = Asteroids(container: self, width: frame.width, height: frame.height, keyPoll: keyPoll)
		game.start()
	}

	override func update(_ currentTime: TimeInterval) {
		game.tickProvider.dispatchTick()
	}

	func shake() {
		// Your code here
		print("Phone has been shaken!")
		ship?
			.add(component: HyperSpaceComponent(x: CGFloat(Int.random(in: 0...Int(game.config.width))),
												y: CGFloat(Int.random(in: 0...Int(game.config.height)))))
	}

	//MARK:- TOUCHES -------------------------

	var flipTouched: UITouch?
	var leftTouched: UITouch?
	var rightTouched: UITouch?
	var triggerTouched: UITouch?
	var thrustTouched: UITouch?
	let generator = UIImpactFeedbackGenerator(style: .heavy)

	func touchDown(atPoint pos: CGPoint, touch: UITouch) {
		//HACK is there a child named "wait"?
		guard childNode(withName: "wait") == nil else {
			game.keyPoll.tapped = true
			generator.impactOccurred()
			return
		}
		guard let nodeTouched = atPoint(pos) == self ? nil : atPoint(pos)
		else { return }
		if let ship,
		   ship.has(componentClassName: MotionComponent.name) {
			if nodeTouched.name == "flipButton" {
				flipTouched = touch
				game.keyPoll.flipIsDown = true
				generator.impactOccurred()
			}
			if nodeTouched.name == "fireButton" {
				triggerTouched = touch
				game.keyPoll.triggerIsDown = true
				generator.impactOccurred()
			}
			if nodeTouched.name == "thrustButton" {
				if game.keyPoll.thrustIsDown == false {
					thrustTouched = touch
					game.keyPoll.thrustIsDown = true
					generator.impactOccurred()
				}
			}
			// either or
			if nodeTouched.name == "leftButton" {
				leftTouched = touch
				game.keyPoll.rightIsDown = false
				game.keyPoll.leftIsDown = true
				generator.impactOccurred()
			} else if nodeTouched.name == "rightButton" {
				rightTouched = touch
				game.keyPoll.leftIsDown = false
				game.keyPoll.rightIsDown = true
				generator.impactOccurred()
			}
		}
	}

	func touchMoved(toPoint pos: CGPoint, touch: UITouch) {
	}

	func touchUp(atPoint pos: CGPoint, touch: UITouch) {
		switch touch {
			case flipTouched:
				flipTouched = nil
				game.keyPoll.flipIsDown = false
			case leftTouched:
				leftTouched = nil
				game.keyPoll.leftIsDown = false
			case rightTouched:
				rightTouched = nil
				game.keyPoll.rightIsDown = false
			case thrustTouched:
				thrustTouched = nil
				game.keyPoll.thrustIsDown = false
			case triggerTouched:
				triggerTouched = nil
				game.keyPoll.triggerIsDown = false
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
