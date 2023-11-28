import UIKit
import SpriteKit
import CoreMotion

final class GameViewController: UIViewController {
	var game: Asteroids!

	override func viewDidLoad() {
		super.viewDidLoad()
		let skview = SKView(frame: CGRect(x: 0, y: 0, width: 1024, height: 768))
		view = skview
		view.isUserInteractionEnabled = true
		let scene = ButtonsGameScene(size: view.frame.size)
		game = Asteroids(scene: scene)
		scene.game = game
		scene.scaleMode = .aspectFit
		skview.isUserInteractionEnabled = true
		skview.isMultipleTouchEnabled = true
		skview.showsPhysics = false
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
}
