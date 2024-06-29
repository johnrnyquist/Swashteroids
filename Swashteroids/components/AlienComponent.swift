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
    //TODO: this may not be the best place for this
    var rotationSpeed: Double {
        switch self {
            case .soldier: return 0.1
            case .worker: return 0.05
        }
    }
    var scoreValue: Int {
        switch self {
            case .soldier: return 350
            case .worker: return 50
        }
    }
}

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
