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

final class GameOverSystem: ListIteratingSystem {
    init() {
        super.init(nodeClass: GameOverNode.self)
        nodeUpdateFunction = updateNode
    }

    private func updateNode(node: Node, time: TimeInterval) {
        guard let appStateComponent = node[AppStateComponent.self]
        else { return }
        appStateComponent.reset()
    }
}


