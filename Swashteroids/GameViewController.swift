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
    func showSettings()
    func hideSettings()
}

final class GameViewController: UIViewController, AlertPresenting {
    var skView: SKView?
    var gameScene: GameScene!
    var swashteroids: Swashteroids!
    var isAlertPresented = false //HACK: this is a hack to prevent the game from starting when the app returns from background.
    var gamePadManager: GamePadInputManager!
    var settingsViewController: UIHostingController<SettingsView>!

    override func loadView() {
        skView = SKView()
        view = skView
    }

    override func viewDidLoad() {
        startNewGame()
    }

    func startNewGame() {
        skView_setup()
        gameScene = gameScene_create()
        swashteroids = swashteroids_create()
        if let gamePadManager {
            gamePadManager.game = swashteroids
        } else {
            gamePadManager = GamePadInputManager(game: swashteroids, size: gameScene.size)
        }
        gameScene_present()
        swashteroids?.start()
    }

    private func skView_setup() {
        skView?.showsPhysics = true
        skView?.ignoresSiblingOrder = true // true is more optimized rendering, but must set zPosition
        skView?.isUserInteractionEnabled = true
        skView?.isMultipleTouchEnabled = true
    }

    private func gameScene_create() -> GameScene {
        let screenSize = UIScreen.main.bounds
        let gameScene = GameScene(size: screenSize.size)
        gameScene.name = "gameScene"
        gameScene.anchorPoint = .zero
        gameScene.scaleMode = .aspectFit
        return gameScene
    }

    private func swashteroids_create() -> Swashteroids {
        let seed = Int(Date().timeIntervalSince1970)
        let swashteroids = Swashteroids(scene: gameScene, alertPresenter: self, seed: seed)
        gameScene.delegate = swashteroids
        gameScene.touchDelegate = swashteroids
        gameScene.physicsWorld.contactDelegate = swashteroids
        gameScene.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        return swashteroids
    }

    private func gameScene_present() {
        skView?.presentScene(gameScene)
    }

    //MARK: - AlertPresenting
    @IBAction func showPauseAlert() {
        guard let swashteroids else { fatalError("game is nil") }
        swashteroids.stop()
        if swashteroids.engine.appStateComponent.swashteroidsState == .playing ||
           swashteroids.engine.appStateComponent.swashteroidsState == .gameOver {
            let alertView = PauseAlert(
                appState: swashteroids.engine.appStateComponent, //HACK
                home: home,
                resume: resume,
                showSettings: showSettings)
            let hostingController = UIHostingController(rootView: alertView)
            hostingController.modalPresentationStyle = .overCurrentContext
            hostingController.view.backgroundColor = UIColor(white: 1, alpha: 0.0)
            present(hostingController, animated: true, completion: nil)
            isAlertPresented = true
        }
    }

    func showSettings() {
        dismiss(animated: true, completion: { [unowned self] in
            gamePadManager.mode = .settings
            let settingsViewController = UIHostingController(rootView:
                                                             SettingsView(
                                                                 gamePadManager: gamePadManager,
                                                                 hide: hideSettings))
            present(settingsViewController, animated: true, completion: nil)
        })
    }

    func hideSettings() {
        dismiss(animated: true, completion: { [weak self] in
            self?.gamePadManager.mode = .game
            self?.showPauseAlert()
        })
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

    func appDidBecomeActive() {
        if isAlertPresented == false {
            swashteroids?.start()
        }
    }

    func appWillResignActive() {
        printAllComponents()
        showPauseAlert()
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

