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

class TreasureCollisionNode: Node {
    required init() {
        super.init()
        components = [
            TreasureComponent.name: nil_component,
            CollidableComponent.name: nil_component,
            PositionComponent.name: nil_component,
        ]
    }
}
