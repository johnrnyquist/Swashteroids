//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import UIKit
import SpriteKit

final class GameViewController: UIViewController {
	var skView: SKView!
	var gameScene: GameScene!

	override func loadView() {
		print(#function)
		skView = SKView()
		skView.showsPhysics = false
		skView.ignoresSiblingOrder = true // true is more optimized rendering, but must set zPosition
		skView.isUserInteractionEnabled = true
		skView.isMultipleTouchEnabled = true
		skView.isUserInteractionEnabled = true
		self.view = skView
	}

	override func viewDidLoad() {
		print(#function)
		super.viewDidLoad()
		
		let screenSize = UIScreen.main.bounds
		let screenWidth = screenSize.width
		let screenHeight = screenSize.height

		gameScene = GameScene(size: CGSize(width: screenWidth, height: screenHeight))
		gameScene.name = "gameScene"
		gameScene.anchorPoint = .zero
		gameScene.scaleMode = .aspectFit

		skView.presentScene(gameScene)
	}

//	override func viewWillLayoutSubviews() {
//		print(#function)
//		super.viewWillLayoutSubviews()
//		gameScene.size = skView.bounds.size
//		skView.presentScene(gameScene)
//	}

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

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        switch UIDevice.current.orientation {
            case .landscapeLeft:
                print("landscapeLeft")
            case .portrait:
                print("portrait")
            case .landscapeRight:
                print("landscapeRight")
            case .portraitUpsideDown:
                print("portraitUpsideDown")
            default:
                break
        }
    }
}
