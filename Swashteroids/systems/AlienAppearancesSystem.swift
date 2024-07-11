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


class AlienAppearancesComponent: Component {
//    var alienNextAppearance: TimeInterval = 0.0
//    var alienAppearanceRateDefault: TimeInterval = 0.0
    static let shared = AlienAppearancesComponent()
    private override init() {}
}

class AlienAppearancesNode: Node {
    required init() {
        super.init()
        components = [
            GameStateComponent.name: nil,
            AlienAppearancesComponent.name: nil,
        ]
    }
}

class AlienAppearancesSystem: ListIteratingSystem {
    private weak var engine: Engine!
    private weak var alienCreator: AlienCreatorUseCase!

    init(alienCreator: AlienCreatorUseCase) {
        super.init(nodeClass: AlienAppearancesNode.self)
        self.alienCreator = alienCreator
        nodeUpdateFunction = updateNode
    }

    override func addToEngine(engine: Engine) {
        super.addToEngine(engine: engine)
        self.engine = engine
    }

    func updateNode(node: Node, time: TimeInterval) {
        guard
            let appStateComponent = node[GameStateComponent.self],
            appStateComponent.gameScreen == .playing
        else { return }
        appStateComponent.alienNextAppearance -= time
        if appStateComponent.alienNextAppearance <= 0 {
            appStateComponent.alienNextAppearance = appStateComponent.alienAppearanceRateDefault
            alienCreator.createAliens()
        }
    }
}




