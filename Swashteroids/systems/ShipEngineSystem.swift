import Foundation
import Swash


final class ShipEngineSystem: ListIteratingSystem {
    init() {
        super.init(nodeClass: ShipEngineNode.self)
        nodeUpdateFunction = updateNode
    }

    private func updateNode(node: Node, time: TimeInterval) {
        guard
            let engineComponent = node[WarpDriveComponent.self],
            let sprite = node[DisplayComponent.self]?.sprite
        else { return }
        //TODO: I'm not crazy about the flag and the child node access here
        if engineComponent.isThrusting {
            sprite.childNode(withName: "//nacelles")?.isHidden = false
        } else {
            sprite.childNode(withName: "//nacelles")?.isHidden = true
        }
    }
}
