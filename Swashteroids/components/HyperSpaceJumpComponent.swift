//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//


import Swash
import Foundation

final class HyperSpaceJumpComponent: Component {
	let x = Double.random(in: 0...1024)
	let y = Double.random(in: 0...1024)
}

final class HyperSpaceEngineComponent: Component {}