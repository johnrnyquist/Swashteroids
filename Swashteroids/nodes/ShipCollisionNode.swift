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

final class ShipCollisionNode: Node {
    required init() {
        super.init()
        components = [
            CollisionComponent.name: nil_component,
            PositionComponent.name: nil_component,
            ShipComponent.name: nil_component,
            MotionComponent.name: nil_component,
            AudioComponent.name: nil_component,
        ]
    }
}
