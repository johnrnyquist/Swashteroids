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

// TODO: Implement a system for this.
// right now it is added to treasures.
// I would also like to add it to torpedoes. maybe.
final class LifetimeComponent: Component {
    var timeRemaining: TimeInterval

    init(timeRemaining: TimeInterval) {
        self.timeRemaining = timeRemaining
    }
}