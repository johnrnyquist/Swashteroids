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

final class PlasmaTorpedoComponent: Component {
    var lifeRemaining: TimeInterval = 0.0

    init(lifeRemaining: TimeInterval) {
        self.lifeRemaining = lifeRemaining
        super.init()
    }
}
