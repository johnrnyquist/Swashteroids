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
import SwiftUI

class MainViewController: UIViewController {
    var gameViewController: GameViewController!
    var settingsViewController: UIHostingController<SettingsView>!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize the game view controller and add it as a child view controller
        gameViewController = GameViewController()
        gameViewController.alertPresenter = self
        addChild(gameViewController)
        view.addSubview(gameViewController.view)
        gameViewController.didMove(toParent: self)
        // Set the frame of the game view controller's view to match the bounds of the main view controller's view
        gameViewController.view.frame = view.bounds
        gameViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // Initialize the settings view controller but don't add it yet
        settingsViewController = UIHostingController(rootView:
                                                     SettingsView(
                                                        gamePadManager: gameViewController.gamePadManager, 
                                                        hide: gameViewController.hideSettings)) //HACK
    }

    func appWillResignActive() {
        // Notify the game view controller that the app will resign active
        gameViewController.appWillResignActive()
    }

    func appDidBecomeActive() {
        // Notify the game view controller that the app did become active
        gameViewController.appDidBecomeActive()
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

extension MainViewController: AlertPresenting {
    func showPauseAlert() {
        // Present the pause alert
        gameViewController.showPauseAlert()
    }

    var isAlertPresented: Bool {
        get {
            return gameViewController.isAlertPresented
        }
        set {
            gameViewController.isAlertPresented = newValue
        }
    }

    func home() {
        // Dismiss the game view controller
        gameViewController.dismiss(animated: true, completion: nil)
    }

    func resume() {
        // Dismiss the pause alert
        gameViewController.resume()
    }

    func showSettings() {
        // Present the settings view controller
        gameViewController.gamePadManager.mode = .settings
        present(settingsViewController, animated: true, completion: nil)
    }

    func hideSettings() {
        // Dismiss the settings view controller
        settingsViewController.dismiss(animated: true, completion: nil)
        gameViewController.gamePadManager.mode = .game
        showPauseAlert()
    }
}
