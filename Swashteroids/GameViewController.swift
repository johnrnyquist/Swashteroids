import UIKit
import SpriteKit

final class GameViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		let skview = SKView(frame: CGRect(x: 0, y: 0, width: 1024, height: 768))
		view = skview
		view.isUserInteractionEnabled = true
		let scene = NoButtonsGameScene(size: view.frame.size)
		scene.scaleMode = .aspectFit
		skview.isUserInteractionEnabled = true
		skview.isMultipleTouchEnabled = true
		skview.showsPhysics = false
		skview.presentScene(scene)
	}

	override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		if motion == .motionShake {
			if 
				let skView = view as? SKView,
				let scene = skView.scene as? Buttons {
				scene.shake()
			}
		}
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
}
