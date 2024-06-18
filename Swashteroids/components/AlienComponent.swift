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

final class AlienComponent: Component {
    var endDestination: CGPoint = .zero
    var killScore: Int
    var reactionTime: TimeInterval
    var startDestination: CGPoint = .zero
    var timeSinceLastReaction: TimeInterval = 0.0
    weak var targetedEntity: Entity?

    init(reactionTime: Double, killScore: Int) {
        self.reactionTime = reactionTime
        self.killScore = killScore
    }
}

class AlienSoldierComponent: Component {
}

class AlienWorkerComponent: Component {
}

