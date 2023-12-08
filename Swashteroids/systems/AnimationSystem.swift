//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import Foundation
import Swash


final class AnimationSystem: ListIteratingSystem {
    init() {
        super.init(nodeClass: AnimationNode.self)
        nodeUpdateFunction = updateNode
    }

	func updateNode(node: Node, time: TimeInterval) {
        guard let animationComponent = node[AnimationComponent.self]
        else { return }
        animationComponent.animation.animate(time)
    }
}
