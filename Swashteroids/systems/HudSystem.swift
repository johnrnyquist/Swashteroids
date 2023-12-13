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


final class HudSystem: ListIteratingSystem {
    init() {
        super.init(nodeClass: HudNode.self)
        nodeUpdateFunction = updateFunction
    }

    private func updateFunction(_ hudNode: Node, _ time: TimeInterval) {
        guard let hudComponent = hudNode[HudComponent.self],
              let appStateComponent = hudNode[AppStateComponent.self]
        else { return }
        hudComponent.hudView.setNumShips(appStateComponent.numShips)
        hudComponent.hudView.setScore(appStateComponent.score)
        hudComponent.hudView.setLevel(appStateComponent.level)
    }
}

