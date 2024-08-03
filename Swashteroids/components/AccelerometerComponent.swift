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
import SpriteKit

final class AccelerometerComponent: Component {
    static let shared = AccelerometerComponent()

    private override init() {}

    var rotate: (isDown: Bool, amount: Double) = (false, 0.0)
}
