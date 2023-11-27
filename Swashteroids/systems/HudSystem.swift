import Foundation
import Swash


final public class HudSystem: ListIteratingSystem {
    init() {
        super.init(nodeClass: HudNode.self)
        nodeUpdateFunction = updateFunction
    }

    private func updateFunction(_ hudNode: Node, _ time: TimeInterval) {
        guard let hudComponent = hudNode[HudComponent.self],
              let gameStateComponent = hudNode[GameStateComponent.self]
        else { return }
        hudComponent.hudView.setNumShips(gameStateComponent.ships)
        hudComponent.hudView.setScore(gameStateComponent.hits)
        hudComponent.hudView.setLevel(gameStateComponent.level)
    }
}

