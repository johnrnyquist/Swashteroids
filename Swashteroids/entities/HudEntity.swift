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
