//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
// Download it from the App Store//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import Swash

final class PlayerNode: Node {
    required init() {
        super.init()
        components = [
            PositionComponent.name: nil_component,
            PlayerComponent.name: nil_component,
        ]
    }
}
