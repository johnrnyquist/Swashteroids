import SpriteKit
import CoreGraphics
import AVFoundation
import Swash

final class GameScene: SKScene {
	var game: Asteroids!
	var ship: Entity?

	override func didMove(to view: SKView) {
		super.didMove(to: view)
		game = Asteroids(container: self, width: frame.width, height: frame.height)
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
		if let wait = game.engine.getEntity(named: "wait"),
		   let input = wait.get(componentClassName: InputComponent.name) as? InputComponent {
			input.tapped = true
			generator.impactOccurred()
			return
		}

		guard let nodeTouched = atPoint(pos) == self ? nil : atPoint(pos)
		else { return }
		if let ship,
		   ship.has(componentClassName: MotionComponent.name),
		   let input = ship.get(componentClassName: InputComponent.name) as? InputComponent
		{
			if nodeTouched.name == "flipButton" {
				flipTouched = touch
				input.flipIsDown = true
				generator.impactOccurred()
			}
			if nodeTouched.name == "fireButton" {
				triggerTouched = touch
				input.triggerIsDown = true
				generator.impactOccurred()
			}
			if nodeTouched.name == "thrustButton" {
				if input.thrustIsDown == false {
					thrustTouched = touch
					input.thrustIsDown = true
					generator.impactOccurred()
				}
			}
			// either or
			if nodeTouched.name == "leftButton" {
				leftTouched = touch
				input.rightIsDown = false
				input.leftIsDown = true
				generator.impactOccurred()
			} else if nodeTouched.name == "rightButton" {
				rightTouched = touch
				input.leftIsDown = false
				input.rightIsDown = true
				generator.impactOccurred()
			}
		}
	}

	func touchMoved(toPoint pos: CGPoint, touch: UITouch) {
	}

	func touchUp(atPoint pos: CGPoint, touch: UITouch) {
		guard let ship,
			  ship.has(componentClassName: MotionComponent.name),
			  ship.has(componentClassName: InputComponent.name),
			  let input = ship.get(componentClassName: InputComponent.name) as? InputComponent
		else { return }
		switch touch {
			case flipTouched:
				flipTouched = nil
				input.flipIsDown = false
			case leftTouched:
				leftTouched = nil
				input.leftIsDown = false
			case rightTouched:
				rightTouched = nil
				input.rightIsDown = false
			case thrustTouched:
				thrustTouched = nil
				input.thrustIsDown = false
			case triggerTouched:
				triggerTouched = nil
				input.triggerIsDown = false
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
