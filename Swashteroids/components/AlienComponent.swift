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
    /// Each cast has a different rotation speed.
    var rotationSpeed: Double {
        switch self {
            case .soldier: return 0.1
            case .worker: return 0.05
        }
    }
    /// Each cast has a different score value.
    var scoreValue: Int {
        switch self {
            case .soldier: return 350
            case .worker: return 50
        }
    }
    var name: String {
        switch self {
            case .soldier: return "soldier"
            case .worker: return "worker"
        }
    }
}

/// Used by aliens to indicate that they are aliens.
/// Has a cast, a score value, and a max targetable range.
/// Also has a destination start and end point.
final class AlienComponent: Component {
    let cast: AlienCast
    var destinationEnd: CGPoint = .zero
    var destinationStart: CGPoint = .zero
    var scoreValue: Int
    let maxTargetableRange: Double

    init(cast: AlienCast, scaleManager: ScaleManaging = ScaleManager.shared) {
        self.cast = cast
        scoreValue = cast.scoreValue
        maxTargetableRange = 300 * scaleManager.SCALE_FACTOR
    }
}

/// Used by aliens to indicate that they are firing.
/// Essentially a flag for the AlienFiringSystem.
final class AlienFiringComponent: Component {
    static let shared = AlienFiringComponent()

    private override init() {}
}

/// Any entity with this component can be shot at by the aliens.
final class AlienCanShootComponent: Component {
    static let shared = AlienCanShootComponent()

    private override init() {}
}

/// Any entity with this component can be targeted by an alien worker (like an asteroid, a treasure, or the player).
final class AlienWorkerTargetComponent: Component {
    static let shared = AlienWorkerTargetComponent()

    private override init() {}
}