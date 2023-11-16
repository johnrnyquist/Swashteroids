import UIKit
import SpriteKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?
	//HACK to preload sounds
	let bangLarge = SKAction.playSoundFileNamed("bangLarge.wav", waitForCompletion: false)
	let bangMedium = SKAction.playSoundFileNamed("bangMedium.wav", waitForCompletion: false)
	let bangSmall = SKAction.playSoundFileNamed("bangSmall.wav", waitForCompletion: false)
	let fire = SKAction.playSoundFileNamed("fire.wav", waitForCompletion: false)
	let thrust = SKAction.playSoundFileNamed("thrust.wav", waitForCompletion: false)
	let hyperspace = SKAction.playSoundFileNamed("hyperspace.wav", waitForCompletion: false)

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		return true
	}
}


