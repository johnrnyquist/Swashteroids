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

// right now it is added to treasures.
// I might add it to torpedoes.
final class LifetimeComponent: Component {
    var timeRemaining: TimeInterval
    var numberOfFlashes: Int

    init(timeRemaining: TimeInterval, numberOfFlashes: Int = 0) {
        self.timeRemaining = timeRemaining
        self.numberOfFlashes = numberOfFlashes
    }
}