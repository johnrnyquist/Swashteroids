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

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var gameViewController: GameViewController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window {
            gameViewController = GameViewController()
            window.rootViewController = gameViewController
            window.makeKeyAndVisible()
            return true
        } else {
            return false
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        save()
        gameViewController.game?.stop()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        gameViewController.game?.start()
    }

    func save() {
        if let entities = gameViewController.game?.engine.entities {
            for entity in entities {
                print(entity)
                for component in entity.getAll() {
                    print("\t", component)
                }
                print("---")
            }
        }
    }
}

var appVersion: String {
    return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
}
var appBuild: String {
    return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
}

