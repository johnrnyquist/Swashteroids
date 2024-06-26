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
    var skView: SKView?
    var gameScene: GameScene?
    var swashteroids: Swashteroids?
    var isAlertPresented = false //HACK: this is a hack to prevent the game from starting when the app returns from background.

    override func loadView() {
        skView = SKView()
        view = skView
    }

    override func viewDidLoad() {
        startNewGame()
    }

    func startNewGame() {
        skView_setup()
        gameScene_create()
        swashteroids_create()
        gameScene_present()
    }

    private func skView_setup() {
        skView?.showsPhysics = true
        skView?.ignoresSiblingOrder = true // true is more optimized rendering, but must set zPosition
        skView?.isUserInteractionEnabled = true
        skView?.isMultipleTouchEnabled = true
    }

    private func gameScene_create() {
        let screenSize = UIScreen.main.bounds
        gameScene = GameScene(size: screenSize.size)
        gameScene?.name = "gameScene"
        gameScene?.anchorPoint = .zero
        gameScene?.scaleMode = .aspectFit
    }

    private func swashteroids_create() {
        guard let gameScene else { fatalError("gameScene is nil") }
        let seed = Int(Date().timeIntervalSince1970)
        swashteroids = Swashteroids(scene: gameScene, alertPresenter: self, seed: seed)
        gameScene.delegate = swashteroids
        gameScene.touchDelegate = swashteroids
        gameScene.physicsWorld.contactDelegate = swashteroids
        gameScene.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        swashteroids?.start()
    }

    private func gameScene_present() {
        skView?.presentScene(gameScene)
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
            swashteroids?.start()
        })
    }

    @IBAction func showPauseAlert() {
        guard let swashteroids else { fatalError("game is nil") }
        swashteroids.stop()
        if swashteroids.engine.appStateComponent.appState == .playing ||
           swashteroids.engine.appStateComponent.appState == .gameOver {
            let alertView = PauseAlert(
                appState: swashteroids.engine.appStateComponent, //HACK
                home: home,
                resume: resume)
            let hostingController = UIHostingController(rootView: alertView)
            hostingController.modalPresentationStyle = .overCurrentContext
            hostingController.view.backgroundColor = UIColor(white: 1, alpha: 0.0)
            present(hostingController, animated: true, completion: nil)
            isAlertPresented = true
        }
    }

    func appDidBecomeActive() {
        if isAlertPresented == false {
            swashteroids?.start()
        }
    }

    func appWillResignActive() {
        printAllComponents()
        showPauseAlert()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            .allButUpsideDown
        } else {
            .all
        }
    }
    override var prefersStatusBarHidden: Bool {
        true
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

    func printAllComponents() {
        if let entities = swashteroids?.engine.entities {
            for entity in entities {
                print(entity.name)
                for component in entity.components {
                    print("\t", type(of: component).name)
                }
                print("---")
            }
        }
    }
}

// For physics
// let playerCategory: UInt32 = 0x1 << 0
// let alienCategory: UInt32 = 0x1 << 1
// let asteroidCategory: UInt32 = 0x1 << 2
// let torpedoCategory: UInt32 = 0x1 << 3
// let powerUpCategory: UInt32 = 0x1 << 4
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
