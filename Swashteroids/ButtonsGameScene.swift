import SpriteKit
import CoreGraphics
import AVFoundation
import Swash


final class ButtonsGameScene: SKScene {
	var game: Asteroids!

	override func didMove(to view: SKView) {
		super.didMove(to: view)
		backgroundColor = .background
		game = Asteroids(scene: self)
		game.start()
	}

	override func update(_ currentTime: TimeInterval) {
		game.dispatchTick()
	}

	//MARK:- TOUCHES -------------------------

	var flipTouched: UITouch?
	var hyperSpaceTouched: UITouch?
	var leftTouched: UITouch?
	var rightTouched: UITouch?
	var triggerTouched: UITouch?
	var thrustTouched: UITouch?
	let generator = UIImpactFeedbackGenerator(style: .heavy)

	func touchDown(atPoint pos: CGPoint, touch: UITouch) {
		if let _ = game.wait {
			game.input.tapped = true
			generator.impactOccurred()
			return
		}
		if let _ = game.gameOver {
			game.input.tapped = true
			generator.impactOccurred()
			return
		}

		guard let nodeTouched = atPoint(pos) == self ? nil : atPoint(pos)
		else { return }
		if let ship = game.ship,
		   ship.has(componentClassName: MotionComponent.name)
		{
			(nodeTouched as! SKSpriteNode).alpha = 0.6

			if nodeTouched.name == InputName.hyperSpaceButton {
				hyperSpaceTouched = touch
				game.input.hyperSpaceIsDown = true
				game.ship?.add(component: HyperSpaceComponent(x: Double(Int.random(in: 0...Int(size.width))),
															  y: Double(Int.random(in: 0...Int(size.height)))))
				generator.impactOccurred()
			}
			if nodeTouched.name == InputName.flipButton {
				flipTouched = touch
				game.input.flipIsDown = true
				generator.impactOccurred()
			}
			if nodeTouched.name == InputName.fireButton {
				triggerTouched = touch
				game.input.triggerIsDown = true
				generator.impactOccurred()
			}
			if nodeTouched.name == InputName.thrustButton {
				if game.input.thrustIsDown == false {
					thrustTouched = touch
					game.input.thrustIsDown = true
					generator.impactOccurred()
				}
			}
			// either or
			if nodeTouched.name == InputName.leftButton {
				leftTouched = touch
				game.input.leftIsDown = true
				generator.impactOccurred()
			} else if nodeTouched.name == InputName.rightButton {
				rightTouched = touch
				game.input.rightIsDown = true
				generator.impactOccurred()
			}
		}
	}

	func touchMoved(toPoint pos: CGPoint, touch: UITouch) {
	}

	func touchUp(atPoint pos: CGPoint, touch: UITouch) {
		guard let ship = game.ship,
			  ship.has(componentClassName: MotionComponent.name),
			  ship.has(componentClassName: InputComponent.name)
		else { return }
		
		switch touch {
			case flipTouched:
				if let node = self.childNode(withName: InputName.flipButton) as? SKSpriteNode {
					node.alpha = 0.2
				}
				flipTouched = nil
				game.input.flipIsDown = false
			case hyperSpaceTouched:
				if let node = self.childNode(withName: InputName.hyperSpaceButton) as? SKSpriteNode {
					node.alpha = 0.2
				}
			hyperSpaceTouched = nil
				game.input.hyperSpaceIsDown = false
			case leftTouched:
				if let node = self.childNode(withName: InputName.leftButton) as? SKSpriteNode {
					node.alpha = 0.2
				}
				leftTouched = nil
				game.input.leftIsDown = false
			case rightTouched:
				if let node = self.childNode(withName: InputName.rightButton) as? SKSpriteNode {
					node.alpha = 0.2
				}
				rightTouched = nil
				game.input.rightIsDown = false
			case thrustTouched:
				if let node = self.childNode(withName: InputName.thrustButton) as? SKSpriteNode {
					node.alpha = 0.2
				}
				thrustTouched = nil
				game.input.thrustIsDown = false
			case triggerTouched:
				if let node = self.childNode(withName: InputName.fireButton) as? SKSpriteNode {
					node.alpha = 0.2
				}
				triggerTouched = nil
				game.input.triggerIsDown = false
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
