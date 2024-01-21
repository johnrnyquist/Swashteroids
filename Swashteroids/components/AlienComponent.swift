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

class AlienComponent: Component {
    weak var targetingEntity: Entity?
    var timeSinceLastReaction: TimeInterval = 0.0
    var reactionTime: TimeInterval = 0.5
    var endDestination: CGPoint = .zero
    var startDestination: CGPoint = .zero
    var killScore = 350

    init(reactionTime: Double, killScore: Int) {
        self.reactionTime = reactionTime
        self.killScore = killScore
    }
}

class AlienSoldierComponent: Component {
}

class AlienWorkerComponent: Component {
}

