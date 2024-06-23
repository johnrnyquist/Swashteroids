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

// TODO: Right now this is an alien-only class because of the AlienComponent
class MoveToTargetNode: Node {
    required init() {
        super.init()
        components = [
            MoveToTargetComponent.name: nil_component,
            PositionComponent.name: nil_component,
            VelocityComponent.name: nil_component,
            AlienComponent.name: nil_component,
        ]
    }
}
