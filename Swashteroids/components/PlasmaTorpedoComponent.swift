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

final class PlasmaTorpedoComponent: Component {
    var owner: OwnerType
    var lifeRemaining: TimeInterval = 2.0

    init(lifeRemaining: TimeInterval, owner: OwnerType) {
        self.lifeRemaining = lifeRemaining
        self.owner = owner
        super.init()
    }
}
