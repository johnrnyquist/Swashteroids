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

final class TorpedoComponent: Component {
    var owner: OwnerType
    weak var ownerEntity: Entity?
    var lifeRemaining: TimeInterval = 2.0

    init(lifeRemaining: TimeInterval, owner: OwnerType, ownerEntity: Entity) {
        self.lifeRemaining = lifeRemaining
        self.owner = owner
        self.ownerEntity = ownerEntity
        super.init()
    }
}
