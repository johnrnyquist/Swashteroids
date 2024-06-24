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

/// Added to entity to target in its own fashion
class MoveToTargetComponent: Component {
    var targetedEntityName: String

    init(target targetedEntity: String) {
        self.targetedEntityName = targetedEntity
    }

    deinit {
        print("MoveToTargetComponent deinit \(self)")
    }
}
