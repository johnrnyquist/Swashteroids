//
// Created by John Nyquist on 11/14/23.
//

import Swash

final class HudEntity: Entity {
    init(name: String, view: HudView) {
        super.init(name: name)
        self.add(component: GameStateComponent())
            .add(component: HudComponent(hudView: view))
            .add(component: DisplayComponent(displayObject: view))
            .add(component: PositionComponent(x: 0, y: 0, z: .hud, rotation: 0))
    }
}
