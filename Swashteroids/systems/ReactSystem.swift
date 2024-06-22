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
class ReactComponent: Component {}

class ReactNode: Node {
    required init() {
        super.init()
        components = [
            AlienSoldierComponent.name: nil_component,
            ReactComponent.name: nil_component,
        ]
    }
}

final class ReactSystem: ListIteratingSystem {
    init() {
        super.init(nodeClass: ReactNode.self)
        nodeUpdateFunction = updateNode
    }

    func updateNode(node: Node, time: TimeInterval) {
        guard let component = node[ReactComponent.self],
              let entity = node.entity
        else { return }
        if entity.has(componentClass: TargetComponent.self) {
            entity.remove(componentClass: type(of: component))
        } else {
            entity.add(component: PickTargetComponent())
        }
    }
}




