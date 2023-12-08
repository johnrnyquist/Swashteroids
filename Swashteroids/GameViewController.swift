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
//import CoreMotion

final class GameViewController: UIViewController {
    override func viewDidLoad() {
        print(self, #function)
        super.viewDidLoad()
        let skview = createView()
        view = skview
        let scene = createScene(size: skview.frame.size)
        skview.presentScene(scene)
    }

    func createScene(size: CGSize) -> SKScene {
        let scene = GameScene(size: size)
        let game = Swashteroids(scene: scene, inputComponent: InputComponent.instance)
        scene.game = game
        scene.name = "gameScene"
        scene.anchorPoint = .zero
        scene.inputComponent = InputComponent.instance
        scene.scaleMode = .aspectFit
        return scene
    }

    func createView() -> SKView {
        let skview = SKView(frame: CGRect(x: 0, y: 0, width: 1024, height: 768))
        skview.showsPhysics = false
        skview.ignoresSiblingOrder = true // true is more optimized rendering, but must set zPosition
        skview.isUserInteractionEnabled = true
        skview.isMultipleTouchEnabled = true
        skview.isUserInteractionEnabled = true
        return skview
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
