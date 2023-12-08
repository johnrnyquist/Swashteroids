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

extension Creator {
    func createHud(gameState: AppStateComponent) {
        // Here we create a subclass of entity
        let hudView = HudView()
        let hudEntity = HudEntity(name: .hud, view: hudView, gameState: gameState)
        engine.replaceEntity(entity: hudEntity)
    }
}
