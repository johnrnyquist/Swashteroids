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

final class AlienFiringNode: Node {
    required init() {
        super.init()
        components = [
            AlienComponent.name: nil,
            AlienFiringComponent.name: nil,
            GunComponent.name: nil,
            MoveToTargetComponent.name: nil,
            PositionComponent.name: nil,
            VelocityComponent.name: nil,
        ]
    }
}
