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

final class ReactionTimeSystem: ListIteratingSystem {
    init() {
        super.init(nodeClass: ReactionTimeNode.self)
        nodeUpdateFunction = updateNode
    }

    func updateNode(node: Node, time: TimeInterval) {
        guard let component = node[ReactionTimeComponent.self],
              let entity = node.entity
        else { return }
        updateAlienReactionTime(component: component, time: time)
        if component.timeSinceLastReaction == 0 {
            entity.add(component: ReactComponent())
        }
    }

    func updateAlienReactionTime(component: ReactionTimeComponent, time: TimeInterval) {
        component.timeSinceLastReaction += time
        if component.timeSinceLastReaction >= component.reactionTime {
            component.timeSinceLastReaction = 0
        }
    }
}


class ReactionTimeComponent: Component {
    var reactionTime: TimeInterval
    var timeSinceLastReaction: TimeInterval = 0.0

    init(reactionTime: Double) {
        self.reactionTime = reactionTime
    }
}

class ReactionTimeNode: Node {
    required init() {
        super.init()
        components = [
            ReactionTimeComponent.name: nil_component,
        ]
    }
}
