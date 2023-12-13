//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import SpriteKit

class PlasmaTorpedoesPowerUpView: SwashteroidsSpriteNode, Animate {
	var time: TimeInterval = 0
	var dir = -1.0

	func animate(_ time: TimeInterval) {
		self.time += time
		if self.time > 1 {
			self.time = 0
			dir = dir == 1.0 ? -1.0 : 1.0
		}
		//        alpha += Double(dir * time / 2)
		//		xScale += Double(dir * time / 10)
		//		yScale += Double(dir * time / 10)
	}
}


class HyperspacePowerUpView: SwashteroidsSpriteNode, Animate {
	var time: TimeInterval = 0
	var dir = -1.0

	func animate(_ time: TimeInterval) {
		self.time += time
		if self.time > 1 {
			self.time = 0
			dir = dir == 1.0 ? -1.0 : 1.0
		}
		//        alpha += Double(dir * time / 2)
		//		xScale += Double(dir * time / 10)
		//		yScale += Double(dir * time / 10)
	}
}
