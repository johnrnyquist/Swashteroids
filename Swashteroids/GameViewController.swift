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

protocol AlertPresenting {
    func showPauseAlert()
}

final class GameViewController: UIViewController, AlertPresenting {
    var skView: SKView!
    var gameScene: GameScene!
    var game: Swashteroids?
    var isAlertPresented = false //HACK: this is a hack to prevent the game from starting when the app returns from background.

    override func loadView() {
        skView = SKView()
        skView.showsPhysics = true
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
        gameScene.delegate = game
        gameScene.touchDelegate = game
        gameScene.physicsWorld.contactDelegate = game
        gameScene.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        game?.start()
        skView.presentScene(gameScene)
    }

    @IBAction func showPauseAlert() {
        game?.stop()
        let alertView = PauseAlert(
            hitPercentage: game!.engine.appState![AppStateComponent.self]!.hitPercentage ?? 0, //HACK
            home: { [unowned self] in
                dismiss(animated: true, completion: { [unowned self] in
                    isAlertPresented = false
                    startNewGame()
                })
            },
            resume: { [unowned self] in
                dismiss(animated: true, completion: { [unowned self] in
                    isAlertPresented = false
                    game?.start()
                })
            })
        let hostingController = UIHostingController(rootView: alertView)
        hostingController.modalPresentationStyle = .overCurrentContext
        hostingController.view.backgroundColor = UIColor(white: 1, alpha: 0.0)
        present(hostingController, animated: true, completion: nil)
        isAlertPresented = true
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

let playerCategory: UInt32 = 0x1 << 0
let alienCategory: UInt32 = 0x1 << 1
let asteroidCategory: UInt32 = 0x1 << 2
let torpedoCategory: UInt32 = 0x1 << 3
let powerUpCategory: UInt32 = 0x1 << 4

extension Swashteroids: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        print(#function)
        if let a = contact.bodyA.node as? SwashSpriteNode,
           let b = contact.bodyB.node as? SwashSpriteNode,
           let ae = a.entity,
           let be = b.entity {
            print("\(ae.name) hit \(be.name)")
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        print(#function)
    }
}
