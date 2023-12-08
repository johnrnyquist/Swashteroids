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
        appStateComponent.playing = false
    }
}


