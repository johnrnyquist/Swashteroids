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

// MARK: - React
class MakeDecisionCompnent: Component {}

class MakeDecisionNode: Node {
    required init() {
        super.init()
        components = [
            AlienComponent.name: nil_component,
            MakeDecisionCompnent.name: nil_component,
            ReactionTimeComponent.name: nil_component,
        ]
    }
}

final class MakeDecisionSystem: ListIteratingSystem {
    init() {
        super.init(nodeClass: MakeDecisionNode.self)
        nodeUpdateFunction = updateNode
    }

    func updateNode(node: Node, time: TimeInterval) {
        guard let component = node[MakeDecisionCompnent.self],
              let reactionTimeComponent = node[ReactionTimeComponent.self],
              let entity = node.entity
        else { return }
        entity.remove(componentClass: type(of: component))
        reactionTimeComponent.reacted()
        entity.add(component: PickTargetComponent())
    }
}




