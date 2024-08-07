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

final class AlienReactionTimeSystem: ListIteratingSystem {
    init() {
        super.init(nodeClass: ReactionTimeNode.self)
        nodeUpdateFunction = updateNode
    }

    func updateNode(node: Node, time: TimeInterval) {
        guard let reactionTimeComponent = node[ReactionTimeComponent.self],
              let entity = node.entity
        else { return }
        reactionTimeComponent.timeSinceLastReaction += time
        if reactionTimeComponent.canReact {
            entity.add(component: PickTargetComponent())
            reactionTimeComponent.reacted()
        }
    }
}
