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

final class GunControlNode: Node {
    required init() {
        super.init()
        components = [
            MotionComponent.name: nil_component,
            PositionComponent.name: nil_component,
            GunComponent.name: nil_component,
            TriggerDownComponent.name: nil_component
        ]
    }
}

