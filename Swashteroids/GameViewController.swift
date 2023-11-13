import UIKit
import SpriteKit

final class GameViewController: UIViewController {
	private var keyPoll = KeyPoll()

	override func viewDidLoad() {
		super.viewDidLoad()
		let skview = SKView(frame: CGRect(x: 0, y: 0, width: 1024, height: 768))
		view = skview
		view.isUserInteractionEnabled = true
		let scene = GameScene(size: view.frame.size)
		scene.keyPoll = keyPoll
		scene.scaleMode = .aspectFit
		skview.showsFPS = true
		skview.isUserInteractionEnabled = true
		skview.isMultipleTouchEnabled = true
		skview.showsPhysics = false
		skview.showsNodeCount = true
		skview.presentScene(scene)
	}

	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		if UIDevice.current.userInterfaceIdiom == .phone {
			return .allButUpsideDown
		} else {
			return .all
		}
	}
	override var prefersStatusBarHidden: Bool {
		return true
	}

	override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
		// Run backward or forward when the user presses a left or right arrow key.
		var didHandleEvent = false
		for press in presses {
			guard let key = press.key else { continue }
			if key.charactersIgnoringModifiers == UIKeyCommand.inputLeftArrow {
				keyPoll.leftIsDown = true
				didHandleEvent = true
			}
			if key.charactersIgnoringModifiers == UIKeyCommand.inputRightArrow {
				keyPoll.rightIsDown = true
				didHandleEvent = true
			}
			if key.charactersIgnoringModifiers == UIKeyCommand.inputUpArrow {
				keyPoll.thrustIsDown = true
				didHandleEvent = true
			}
			if key.charactersIgnoringModifiers == UIKeyCommand.inputDownArrow {
				keyPoll.aftTriggerIsDown = true
				didHandleEvent = true
			}
			if key.keyCode == .keyboardSpacebar {
				keyPoll.triggerIsDown = true
				didHandleEvent = true
			}
		}
		if didHandleEvent == false {
			// Didn't handle this key press, so pass the event to the next responder.
			super.pressesBegan(presses, with: event)
		}
	}

	override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
		// Stop running when the user releases the left or right arrow key.
		var didHandleEvent = false
		for press in presses {
			guard let key = press.key else { continue }
			if key.charactersIgnoringModifiers == UIKeyCommand.inputLeftArrow {
				keyPoll.leftIsDown = false
				didHandleEvent = true
			}
			if key.charactersIgnoringModifiers == UIKeyCommand.inputRightArrow {
				keyPoll.rightIsDown = false
				didHandleEvent = true
			}
			if key.charactersIgnoringModifiers == UIKeyCommand.inputUpArrow {
				keyPoll.thrustIsDown = false
				didHandleEvent = true
			}
			if key.charactersIgnoringModifiers == UIKeyCommand.inputDownArrow {
				keyPoll.aftTriggerIsDown = false
				didHandleEvent = true
			}
			if key.keyCode == .keyboardSpacebar {
				keyPoll.triggerIsDown = false
				didHandleEvent = true
			}
		}
		if didHandleEvent == false {
			// Didn't handle this key press, so pass the event to the next responder.
			super.pressesBegan(presses, with: event)
		}
	}
}
