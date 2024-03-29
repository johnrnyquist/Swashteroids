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

final class CollidableComponent: Component {
    var radius = 0.0

    init(radius: Double, scaleManager: ScaleManaging = ScaleManager.shared) {
        self.radius = radius * scaleManager.SCALE_FACTOR
        super.init()
    }
}
