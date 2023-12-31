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

extension Creator: HudManager, AlertPresenter {
    func createHud(gameState: AppStateComponent) {
        let hudEntity = HudEntity(name: .hud, gameState: gameState)
        let pauseButton = hudEntity.view.pauseButton!
        pauseButton.removeFromParent()
        let position = PositionComponent(x: pauseButton.x, y: pauseButton.y, z: .hud, rotationDegrees: 0)
        let pause = Entity(name: .pauseButton) //HACK
                .add(component: position)
                .add(component: DisplayComponent(sknode: pauseButton))
                .add(component: TouchableComponent())
                .add(component: ButtonBehaviorComponent { node in
                    self.alertPresenter?.showPauseAlert()
                })
        pauseButton.entity = pause
        do {
            try engine.addEntity(entity: hudEntity)
            try engine.addEntity(entity: pause)
        } catch SwashError.entityNameAlreadyInUse(let message) {
            fatalError(message)
        } catch {
            fatalError("Unexpected error: \(error).")
        }
    }

    func showPauseAlert() {
        alertPresenter?.showPauseAlert()
    }
}

final class HudEntity: Entity {
    var view: HudView

    init(name: String, gameState: AppStateComponent) {
        view = HudView(gameSize: gameState.size)
        super.init(name: name)
        add(component: HudComponent(hudView: view))
        add(component: DisplayComponent(sknode: view))
        add(component: PositionComponent(x: 0, y: 0, z: .hud, rotationDegrees: 0))
        add(component: gameState)
    }
}
