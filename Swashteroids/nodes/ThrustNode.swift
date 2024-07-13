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

final class ThrustNode: Node {
    required init() {
        super.init()
        components = [
            PositionComponent.name: nil,
            ApplyThrustComponent.name: nil,
            VelocityComponent.name: nil,
            MovementRateComponent.name: nil,
            ImpulseDriveComponent.name: nil,
        ]
    }
}
