import Foundation
import Swash


public class HudSystem: ListIteratingSystem {
    init() {
        super.init(nodeClass: HudNode.self)
        nodeUpdateFunction = updateFunction
    }

    private func updateFunction(_ hudNode: Node, _ time: TimeInterval) {
        guard let hudComponent = hudNode[HudComponent.self],
              let gameStateComponent = hudNode[GameStateComponent.self]
        else { return }
        hudComponent.hudView.setLives(gameStateComponent.lives)
        hudComponent.hudView.setScore(gameStateComponent.hits)
        hudComponent.hudView.setLevel(gameStateComponent.level)
    }
}

