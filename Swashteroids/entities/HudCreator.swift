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

class HudCreator: HudCreatorUseCase, PauseAlertPresenting {
    private weak var engine: Engine!
    private weak var alertPresenter: PauseAlertPresenting?

    init(engine: Engine, alertPresenter: PauseAlertPresenting) {
        self.engine = engine
        self.alertPresenter = alertPresenter
    }

    func createHud(gameState: GameStateComponent) {
        let view = HudView(gameSize: gameState.gameSize)
        view.name = "hud"
        let hudEntity = Entity(named: .hud)
                .add(component: HudComponent(hudView: view))
                .add(component: DisplayComponent(sknode: view))
                .add(component: PositionComponent(x: 0, y: 0, z: .hud, rotationDegrees: 0))
                .add(component: gameState)
        let pauseButton = view.pauseButton!
        pauseButton.name = "pauseButton"
        pauseButton.removeFromParent()
        let position = PositionComponent(x: pauseButton.x, y: pauseButton.y, z: .hud, rotationDegrees: 0)
        let pause = Entity(named: .pauseButton) //HACK
                .add(component: position)
                .add(component: DisplayComponent(sknode: pauseButton))
                .add(component: ButtonPauseComponent())
                .add(component: TouchableComponent())
                .add(component: ButtonComponent())
                .add(component: HapticFeedbackComponent.shared)
                .add(component: ButtonBehaviorComponent { node in
                    self.alertPresenter?.showPauseAlert()
                })
        pauseButton.entity = pause
        engine.add(entity: hudEntity)
        engine.add(entity: pause)
    }

    func showPauseAlert() {
        alertPresenter?.showPauseAlert()
    }

    var isAlertPresented: Bool {
        get {
            alertPresenter?.isAlertPresented ?? false
        }
        set {
            alertPresenter?.isAlertPresented = newValue
        }
    }

    func home() {
        alertPresenter?.home()
    }

    func resume() {
        alertPresenter?.resume()
    }
    
    func showSettings() {
        alertPresenter?.showSettings()
    }
    
    func hideSettings() {
        alertPresenter?.hideSettings()
    }
}

