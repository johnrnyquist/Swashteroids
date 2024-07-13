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

final class ReactionTimeComponent: Component {
    var reactionSpeed: TimeInterval
    var timeSinceLastReaction: TimeInterval = 0.0

    // MARK: - Computed Properties
    var canReact: Bool {
        timeSinceLastReaction >= reactionSpeed
    }

    init(reactionSpeed: Double) {
        print("ReactionTimeComponent", reactionSpeed)
        self.reactionSpeed = reactionSpeed
    }

    func reacted() {
        timeSinceLastReaction = 0
    }
}
