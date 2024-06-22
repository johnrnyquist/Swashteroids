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
            AlienComponent.name: nil_component,
            AlienFiringComponent.name: nil_component,
            GunComponent.name: nil_component,
            PositionComponent.name: nil_component,
            VelocityComponent.name: nil_component,
            TargetComponent.name: nil_component,
        ]
    }
}

final class AlienWorkerTargetNode: Node {
    required init() {
        super.init()
        components = [
            AlienWorkerTargetComponent.name: nil_component,
            PositionComponent.name: nil_component,
        ]
    }
}
