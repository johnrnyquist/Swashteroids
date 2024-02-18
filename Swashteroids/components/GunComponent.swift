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
import SpriteKit

enum OwnerType {
    case player
    case computerOpponent
}

final class GunComponent: Component {
    var numTorpedoes: Int
    var minimumShotInterval: TimeInterval = 0.25
    var offsetFromParent = CGPoint(x: 21, y: 0)
    var ownerType: OwnerType
    weak var ownerEntity: Entity!
    var rotation = 0.0
    var timeSinceLastShot: TimeInterval = Double.infinity
    var torpedoColor: UIColor = .torpedo
    var torpedoLifetime: TimeInterval = 2.0

    init(offsetX: Double, offsetY: Double, minimumShotInterval: TimeInterval, torpedoLifetime: TimeInterval, torpedoColor: UIColor = .torpedo, ownerType: OwnerType, ownerEntity: Entity, numTorpedoes: Int) {
        offsetFromParent = CGPoint(x: offsetX, y: offsetY)
        self.minimumShotInterval = minimumShotInterval
        self.torpedoLifetime = torpedoLifetime
        self.torpedoColor = torpedoColor
        self.ownerType = ownerType
        self.numTorpedoes = numTorpedoes
        self.ownerEntity = ownerEntity
    }
}
