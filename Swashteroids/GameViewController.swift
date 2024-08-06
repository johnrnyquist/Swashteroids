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
import GameController

enum CurrentViewController {
    case game
    case settings
}

final class GameViewController: UIViewController, PauseAlertPresenting {
    private var skView: SKView?
    private var scene: GameScene!
    private var swashteroids: Swashteroids!
    private var gamepadManager: GamepadManager?
    private var settingsViewController: UIHostingController<SettingsView>!
    /// Flag to prevent the game from starting when the app returns from background.
    var isAlertPresented = false

    override func loadView() {
        super.loadView()
        skView = SKView()
        view = skView
        AudioAsset.validateAudioFilesExist()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        skView_setup()
        startNewGame()
    }

    private func skView_setup() {
        guard let skView else { fatalError("skView is nil") }
        skView.showsPhysics = false
        skView.ignoresSiblingOrder = true // true is more optimized rendering, but must set zPosition
        skView.isUserInteractionEnabled = true
        skView.isMultipleTouchEnabled = true
    }

    func startNewGame() {
        scene = scene_create(size: UIScreen.main.bounds.size)
        swashteroids = swashteroids_create(scene: scene)
        gamepadManager = gamepadManager_create()
        scene_present()
        swashteroids?.start()
    }

    private func scene_create(size: CGSize) -> GameScene {
        let gameScene = GameScene(size: size)
        gameScene.anchorPoint = .zero
        gameScene.scaleMode = .aspectFit
        return gameScene
    }

    private func swashteroids_create(scene: GameScene) -> Swashteroids {
        let seed = Int(Date().timeIntervalSince1970)
        print("seed", seed)
        var config = GameConfig(gameSize: scene.size)
        if let _ = gamepadManager?.pad {
            config.shipControlsState = .usingGamepad
        }
        let swashteroids = Swashteroids(config: config,
                                        scene: scene,
                                        alertPresenter: self,
                                        seed: seed,
                                        touchManager: TouchManager(scene: scene))
        scene.delegate = swashteroids //SKSceneDelegate
        scene.touchDelegate = swashteroids //TouchDelegate
        scene.physicsWorld.contactDelegate = swashteroids //SKPhysicsContactDelegate
        scene.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        return swashteroids
    }

    private func gamepadManager_create() -> GamepadManager? {
        if let gamepadManager,
           let _ = gamepadManager.pad {
            gamepadManager.controllerDidDisconnect()
            gamepadManager.game = swashteroids
            gamepadManager.controllerDidConnect()
            return gamepadManager
        } else {
            gamepadManager = GamepadManager(game: swashteroids, size: scene.size)
            return gamepadManager
        }
    }

    private func scene_present() {
        skView?.presentScene(scene)
    }

    //MARK: - AlertPresenting
    func showPauseAlert() {
        guard let swashteroids else { fatalError("game is nil") }
        swashteroids.stop()
        if swashteroids.engine.gameStateComponent.gameScreen == .playing ||
           swashteroids.engine.gameStateComponent.gameScreen == .gameOver ||
           swashteroids.engine.gameStateComponent.gameScreen == .tutorial {
            let alertView = PauseAlert(
                appState: swashteroids.gameStateComponent,
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
            guard let gamepadManager else { return }
            gamepadManager.mode = .settings
            let settingsViewController = UIHostingController(rootView:
                                                             SettingsView(
                                                                 gamepadManager: gamepadManager,
                                                                 hide: hideSettings))
            present(settingsViewController, animated: true, completion: nil)
        })
    }

    func hideSettings() {
        dismiss(animated: true, completion: { [weak self] in
            self?.gamepadManager?.mode = .game
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
        if let a = contact.bodyA.node as? SwashSpriteNode,
           let b = contact.bodyB.node as? SwashSpriteNode,
           let ae = a.swashEntity,
           let be = b.swashEntity {
            print("\(ae.name) hit \(be.name)")
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
    }
}

