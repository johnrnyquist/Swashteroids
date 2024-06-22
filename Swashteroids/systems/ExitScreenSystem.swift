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

// MARK: - ExitScreen
class ExitScreenComponent: Component {}

class ExitScreenNode: Node {
    required init() {
        super.init()
        components = [
            ExitScreenComponent.name: nil_component,
            PositionComponent.name: nil_component,
            AlienComponent.name: nil_component,
        ]
    }
}

final class ExitScreenSystem: ListIteratingSystem {
    var engine: Engine!

    init() {
        super.init(nodeClass: ExitScreenNode.self)
        nodeUpdateFunction = updateNode
    }

    override func addToEngine(engine: Engine) {
        super.addToEngine(engine: engine)
        self.engine = engine
    }

    func updateNode(node: Node, time: TimeInterval) {
        guard let component = node[ExitScreenComponent.self],
              let position = node[PositionComponent.self],
              let alienComponent = node[AlienComponent.self],
              let entity = node.entity
        else { return }
        if hasReachedDestination(position.x, alienComponent.destinationEnd) {
            entity.remove(componentClass: type(of: component))
            engine?.remove(entity: entity)
        }
    }

    func hasReachedDestination(_ x: Double, _ endDestination: CGPoint) -> Bool {
        if endDestination.x > 0 {
            return x >= endDestination.x
        } else {
            return x <= endDestination.x
        }
    }
}
