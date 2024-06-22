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

class ReactionTimeComponent: Component {
    var reactionSpeed: TimeInterval
    var timeSinceLastReaction: TimeInterval = 0.0
    
    // MARK: - Computed Properties
    var canReact: Bool { timeSinceLastReaction >= reactionSpeed }

    init(reactionSpeed: Double) {
        self.reactionSpeed = reactionSpeed
    }

    func reacted() {
        timeSinceLastReaction = 0
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

final class ReactionTimeSystem: ListIteratingSystem {
    init() {
        super.init(nodeClass: ReactionTimeNode.self)
        nodeUpdateFunction = updateNode
    }

    func updateNode(node: Node, time: TimeInterval) {
        guard let component = node[ReactionTimeComponent.self],
              let entity = node.entity
        else { return }
        component.timeSinceLastReaction += time
        if component.canReact {
            entity.add(component: MakeDecisionCompnent())
        }
    }
}
