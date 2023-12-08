//
// Created by John Nyquist on 11/14/23.
//

import Swash

final class HudEntity: Entity {
    init(name: String, view: HudView, gameState: AppStateComponent) {
		super.init(name: name)
        self
            .add(component: HudComponent(hudView: view))
            .add(component: DisplayComponent(sknode: view))
            .add(component: PositionComponent(x: 0, y: 0, z: .hud, rotation: 0))
			.add(component: gameState)
    }
}
