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

extension Creator: HudCreator, AlertPresenting {
    func createHud(gameState: AppStateComponent) {
        let view = HudView(gameSize: gameState.gameSize)
        let hudEntity = Entity(named: .hud)
                .add(component: HudComponent(hudView: view))
                .add(component: DisplayComponent(sknode: view))
                .add(component: PositionComponent(x: 0, y: 0, z: .hud, rotationDegrees: 0))
                .add(component: gameState)
        let pauseButton = view.pauseButton!
        pauseButton.removeFromParent()
        let position = PositionComponent(x: pauseButton.x, y: pauseButton.y, z: .hud, rotationDegrees: 0)
        let pause = Entity(named: .pauseButton) //HACK
                .add(component: position)
                .add(component: DisplayComponent(sknode: pauseButton))
                .add(component: TouchableComponent())
                .add(component: ButtonBehaviorComponent { node in
                    self.alertPresenter?.showPauseAlert()
                })
        pauseButton.entity = pause
        do {
            try engine.add(entity: hudEntity)
            try engine.add(entity: pause)
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

