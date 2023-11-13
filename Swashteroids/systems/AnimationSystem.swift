import Foundation
import Swash


class AnimationSystem: ListIteratingSystem {
    init() {
        super.init(nodeClass: AnimationNode.self)
        nodeUpdateFunction = updateNode
    }

    private func updateNode(node: Node, time: TimeInterval) {
        guard let animationComponent = node[AnimationComponent.self]
        else { return }
        animationComponent.animation.animate(time)
    }
}
