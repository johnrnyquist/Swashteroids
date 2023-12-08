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

final class PlasmaTorpedoCollisionNode: Node {
    required init() {
        super.init()
        components = [
            PlasmaTorpedoComponent.name: nil_component,
            CollisionComponent.name: nil_component,
            PositionComponent.name: nil_component,
        ]
    }
}
