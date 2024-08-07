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

final class ToggleShipControlsCreator: ToggleShipControlsCreatorUseCase {
    private let engine: Engine
    private let scaleManager: ScaleManaging
    private let size: CGSize

    init(engine: Engine,
         size: CGSize,
         scaleManager: ScaleManaging = ScaleManager.shared) {
        self.engine = engine
        self.size = engine.gameStateComponent.gameSize
        self.scaleManager = ScaleManager.shared
    }

    func removeToggleButton() {
        guard let entity = engine.findEntity(named: .toggleButton) else { return }
        engine.remove(entity: entity)
    }

    func createToggleButton(_ toggleState: Toggle) {
        let sprite = toggleState == .on ? AssetImage.toggleButtonsOn.swashScaledSprite : AssetImage.toggleButtonsOff.swashScaledSprite
        sprite.alpha = 0.2
        let x = size.width / 2
        let y = sprite.height + 25
        let toggleEntity = Entity(named: .toggleButton)
                .add(component: PositionComponent(x: x, y: y, z: .top))
                .add(component: DisplayComponent(sknode: sprite))
                .add(component: TouchableComponent())
                .add(component: HapticFeedbackComponent.shared)
                .add(component: ButtonToggleComponent())
                .add(component: ButtonComponent())
        sprite.swashEntity = toggleEntity
        engine.add(entity: toggleEntity)
    }
}
