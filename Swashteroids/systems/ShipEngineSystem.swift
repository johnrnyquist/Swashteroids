import Foundation
import Swash


class ShipEngineSystem: ListIteratingSystem {
    init() {
        super.init(nodeClass: ShipEngineNode.self)
        nodeUpdateFunction = updateNode
    }

    private func updateNode(node: Node, time: TimeInterval) {
        guard
            let engineComponent = node[EngineComponent.self],
            let displayComponent = node[DisplayComponent.self]
        else { return }
        if engineComponent.isThrusting {
            displayComponent.displayObject?.childNode(withName: "//engine")?.isHidden = false
        } else {
            displayComponent.displayObject?.childNode(withName: "//engine")?.isHidden = true
        }
    }
}
