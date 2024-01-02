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

final class RightNode: Node {
    required init() {
        super.init()
        components = [
            PositionComponent.name: nil_component,
            MovementRateComponent.name: nil_component,
            RightComponent.name: nil_component,
        ]
    }
}
