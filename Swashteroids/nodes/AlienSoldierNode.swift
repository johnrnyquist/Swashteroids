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

class AlienSoldierNode: Node {
    required init() {
        super.init()
        components = [
            AlienSoldierComponent.name: nil_component,
            AlienComponent.name: nil_component,
            PositionComponent.name: nil_component,
            VelocityComponent.name: nil_component,
        ]
    }
}

class AlienWorkerNode: Node {
    required init() {
        super.init()
        components = [
            AlienWorkerComponent.name: nil_component,
            AlienComponent.name: nil_component,
            PositionComponent.name: nil_component,
            VelocityComponent.name: nil_component,
        ]
    }
}
