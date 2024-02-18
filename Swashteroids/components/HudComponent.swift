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

/// This is really a special DisplayComponent.
final class HudComponent: Component {
    weak var hudView: HudView?

    init(hudView: HudView) {
        self.hudView = hudView
    }
}
