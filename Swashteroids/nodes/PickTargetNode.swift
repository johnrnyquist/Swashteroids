//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import Foundation
import Swash

// Right now this is an alien-only class because of the AlienComponent
// but it could be generalized to any entity that needs to pick a target.
class PickTargetNode: Node {
    required init() {
        super.init()
        components = [
            AlienComponent.name: nil,
            PickTargetComponent.name: nil,
            PositionComponent.name: nil,
            VelocityComponent.name: nil,
            GunComponent.name: nil,
        ]
    }
}

