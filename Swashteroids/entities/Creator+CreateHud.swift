//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import Swash
import SpriteKit

protocol HudManager {
    func createHud(gameState: AppStateComponent)
}

extension Creator: HudManager {
    func createHud(gameState: AppStateComponent) {
        let hudEntity = HudEntity(name: .hud, gameState: gameState)
        do {
            try engine.addEntity(entity: hudEntity)
        } catch SwashError.entityNameAlreadyInUse(let message) {
            fatalError(message)
        } catch {
            fatalError("Unexpected error: \(error).")
        }
    }
}

final class HudEntity: Entity {
    init(name: String, gameState: AppStateComponent) {
        super.init(name: name)
        let view = HudView(gameSize: gameState.size)
        add(component: HudComponent(hudView: view))
        add(component: DisplayComponent(sknode: view))
        add(component: PositionComponent(x: 0, y: 0, z: .hud, rotation: 0))
        add(component: gameState)
    }
}
