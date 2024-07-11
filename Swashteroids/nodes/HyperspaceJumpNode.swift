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

final class HyperspaceJumpNode: Node {
    required init() {
        super.init()
        components = [
            DoHyperspaceJumpComponent.name: nil,
            HyperspaceDriveComponent.name: nil,
            PositionComponent.name: nil,
            DisplayComponent.name: nil,
        ]
    }
}

final class HyperspaceNode: Node {
    required init() {
        super.init()
        components = [
            HyperspaceDriveComponent.name: nil,
        ]
    }
}
