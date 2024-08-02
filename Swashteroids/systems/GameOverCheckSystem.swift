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
import SpriteKit
import Swash

final class GameOverCheckSystem: System {
    private weak var appStates: NodeList!
    private weak var engine: Engine!
    // MARK: - System Overrides
    override func addToEngine(engine: Engine) {
        self.engine = engine
        appStates = engine.getNodeList(nodeClassType: SwashteroidsStateNode.self)
    }

    override func removeFromEngine(engine: Engine) {
        appStates = nil
        self.engine = nil
    }

    override func update(time: TimeInterval) {
        guard let currentStateNode = appStates.head as? SwashteroidsStateNode,
              let entity = currentStateNode.entity,
              let appStateComponent = currentStateNode[GameStateComponent.self],
              appStateComponent.gameScreen == .playing
        else { return }
        if appStateComponent.numShips == 0,
           engine.getNodeList(nodeClassType: DeathThroesNode.self).head == nil {
            entity.add(component: ChangeGameStateComponent(from: .playing, to: .gameOver))
        }
    }
}

