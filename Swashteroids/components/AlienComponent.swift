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

enum AlienCast {
    case soldier
    case worker
}

final class AlienComponent: Component {
    let cast: AlienCast
    var destinationEnd: CGPoint = .zero
    var destinationStart: CGPoint = .zero
    var reactionTime: TimeInterval
    var scoreValue: Int
    var timeSinceLastReaction: TimeInterval = 0.0
    weak var targetedEntity: Entity?
    let maxTargetableRange: Double

    init(cast: AlienCast, reactionTime: Double, scoreValue: Int, scaleManager: ScaleManaging = ScaleManager.shared) {
        self.cast = cast
        self.reactionTime = reactionTime
        self.scoreValue = scoreValue
        maxTargetableRange = 300 * scaleManager.SCALE_FACTOR
    }
}

class AlienSoldierComponent: Component {
}

class AlienWorkerComponent: Component {
}

