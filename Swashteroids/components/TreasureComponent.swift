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
import Foundation
import SpriteKit

enum TreasureType {
    case standard
    case special
    var color: UIColor {
        switch self {
            case .standard:
                return .treasureStandard
            case .special:
                return .treasureSpecial
        }
    }
    var value: Int {
        switch self {
            case .standard:
                return 75
            case .special:
                return 350
        }
    }
}

/// Used by the asteroid entities
final class TreasureInfoComponent: Component {
    let type: TreasureType

    init(of type: TreasureType) {
        self.type = type
    }
}

/// Used by the treasure entities, used for Collisions
final class TreasureComponent: Component {
    let type: TreasureType

    init(type: TreasureType) {
        self.type = type
    }
}

final class TreasureInfoNode: Node {
    required init() {
        super.init()
        components = [
            TreasureInfoComponent.name: nil,
            DisplayComponent.name: nil,
        ]
    }
}
