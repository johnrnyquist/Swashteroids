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

protocol AlertPresenting: AnyObject {
    func showPauseAlert()
    var isAlertPresented: Bool { get set }
    func home()
    func resume()
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
        gameScene = nil
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        gameScene = GameScene(size: CGSize(width: screenWidth, height: screenHeight))
        gameScene.name = "gameScene"
        gameScene.anchorPoint = .zero
        gameScene.scaleMode = .aspectFit
        game = Swashteroids(scene: gameScene, alertPresenter: self, seed: Int(Date().timeIntervalSince1970))
        gameScene.delegate = game
        gameScene.touchDelegate = game
        gameScene.physicsWorld.contactDelegate = game
        gameScene.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        game?.start()
        skView.presentScene(gameScene)
    }

    func home() {
            dismiss(animated: true, completion: { [unowned self] in
                isAlertPresented = false
                startNewGame()
            })
    }

    func resume() {
            dismiss(animated: true, completion: { [unowned self] in
                isAlertPresented = false
                game?.start()
            })
    }

    @IBAction func showPauseAlert() {
        game?.stop()
        if game?.engine.appStateComponent.appState == .playing ||
            game?.engine.appStateComponent.appState == .gameOver {
            let alertView = PauseAlert(
                appState: game!.engine.appStateComponent, //HACK
                home: self.home,
                resume: self.resume)
            let hostingController = UIHostingController(rootView: alertView)
            hostingController.modalPresentationStyle = .overCurrentContext
            hostingController.view.backgroundColor = UIColor(white: 1, alpha: 0.0)
            present(hostingController, animated: true, completion: nil)
            isAlertPresented = true
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
