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

final class MoveToTargetComponent: Component {
    let hunterEntityName: String
    var targetedEntityName: String

    init(hunterName: String, targetName: String) {
        hunterEntityName = hunterName
        targetedEntityName = targetName
    }
}
