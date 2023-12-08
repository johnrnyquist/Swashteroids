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


final class NacelleSystem: ListIteratingSystem {
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
