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
import SwiftUI

protocol AlertPresenter {
    func showPauseAlert()
}

final class GameViewController: UIViewController, AlertPresenter {
    var skView: SKView!
    var gameScene: GameScene!
    var game: Swashteroids!
    var alertPresenter: AlertPresenter!

    override func loadView() {
        skView = SKView()
        skView.showsPhysics = false
        skView.ignoresSiblingOrder = true // true is more optimized rendering, but must set zPosition
        skView.isUserInteractionEnabled = true
        skView.isMultipleTouchEnabled = true
        view = skView
    }

    override func viewDidLoad() {
        startNewGame()
    }
    
    func startNewGame() {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        //TODO: I'm not crazy about the bi-directional dependency between game and gameScene, need to consider other options.
        gameScene = GameScene(size: CGSize(width: screenWidth, height: screenHeight))
        gameScene.name = "gameScene"
        gameScene.anchorPoint = .zero
        gameScene.scaleMode = .aspectFit
        game = Swashteroids(scene: gameScene, alertPresenter: self)
        game.alertPresenter = self
        gameScene.delegate = game
        gameScene.touchDelegate = game
        game.start()
        skView.presentScene(gameScene)
    }

    @IBAction func showPauseAlert() {
        game.stop()
        let alertView = PauseAlert(
            home: { [unowned self] in
                dismiss(animated: true, completion: { [unowned self] in 
                    startNewGame()
                })
            },
            restart: { [unowned self] in
                dismiss(animated: true, completion: { [unowned self] in 
                    //TODO: need to implement restart
                })
            },
            resume: { [unowned self] in
                dismiss(animated: true, completion: { [unowned self] in 
                    game.start()
                })
            })
        let hostingController = UIHostingController(rootView: alertView)
        hostingController.modalPresentationStyle = .overCurrentContext
        hostingController.view.backgroundColor = UIColor(white: 1, alpha: 0.0)
        present(hostingController, animated: true, completion: nil)
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
