import UIKit
import SpriteKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    //HACK to preload sounds, we're not running them so you won't hear them
    let bangLarge = SKAction.playSoundFileNamed("bangLarge.wav", waitForCompletion: false)
    let bangMedium = SKAction.playSoundFileNamed("bangMedium.wav", waitForCompletion: false)
    let bangSmall = SKAction.playSoundFileNamed("bangSmall.wav", waitForCompletion: false)
    let fire = SKAction.playSoundFileNamed("fire.wav", waitForCompletion: false)
    let thrust = SKAction.playSoundFileNamed("thrust.wav", waitForCompletion: false)
    let hyperspace = SKAction.playSoundFileNamed("hyperspace.wav", waitForCompletion: false)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print(self, #function)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
}

var appVersion: String {
    return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
}
var appBuild: String {
    return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
}

