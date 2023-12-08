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

final class HyperSpaceNode: Node {
	required init() {
		super.init()
		components = [
			HyperSpaceJumpComponent.name: nil_component,
			HyperSpaceEngineComponent.name: nil_component,
			PositionComponent.name: nil_component,
			DisplayComponent.name: nil_component,
		]
	}
}
