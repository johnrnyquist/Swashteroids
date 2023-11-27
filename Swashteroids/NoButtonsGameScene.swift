import SpriteKit
import CoreGraphics
import AVFoundation
import Swash


final class NoButtonsGameScene: SKScene {
	var do_flip = false
	var do_fire = false
	var do_hyperSpace = false

	var game: Asteroids!

	override func didMove(to view: SKView) {
		super.didMove(to: view)
		backgroundColor = .background
		game = Asteroids(scene: self)
		game.start()
	}

	override func update(_ currentTime: TimeInterval) {
		if let ship = game.ship,
		   ship.has(componentClassName: MotionComponent.name)
		{
			if do_fire {
				game.input.triggerIsDown = true
			}
			if do_hyperSpace {
				do_hyperSpace = false
				game.input.hyperSpaceIsDown = true
				game.ship?.add(component: HyperSpaceComponent(x: Double(Int.random(in: 0...Int(size.width))),
															  y: Double(Int.random(in: 0...Int(size.height)))))
			}
			if do_flip {
				print("flip button tapped")
				do_flip = false
				game.input.flipIsDown = true
			}
		}
		game.dispatchTick()
	}

	func touchDown(atPoint pos: CGPoint) {
		if let _ = game.wait {
			game.input.tapped = true
			return
		}
		if let _ = game.gameOver {
			game.input.tapped = true
			return
		}

		if pos.x > size.width/2 {
			if pos.y < size.height/2 {
				do_fire = true
			} else {
				do_fire = true
			}
		} else {
			if pos.y < size.height/2 {
				do_flip = true
			} else {
				do_hyperSpace = true
			}
		}
	}

	func touchMoved(toPoint pos: CGPoint) {
	}

	func touchUp(atPoint pos: CGPoint) {
		if pos.x > size.width/2 {
			if pos.y < size.height/2 {
			} else {
			}
			do_fire = false
			game.input.triggerIsDown = false
			
		} else {
			if pos.y < size.height/2 {
				do_flip = false
				game.input.flipIsDown = false
				
			} else {
				do_hyperSpace = false
				game.input.hyperSpaceIsDown = false
			}
		}
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches { self.touchDown(atPoint: t.location(in: self)); break }
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches { self.touchMoved(toPoint: t.location(in: self)); break }
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches { self.touchUp(atPoint: t.location(in: self)); break }
	}

	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches { self.touchUp(atPoint: t.location(in: self)); break }
	}

	override var isUserInteractionEnabled: Bool {
		get { true }
		set {}
	}
}
