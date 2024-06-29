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

final class TransitionAppStateComponent: Component {
    var from: GameState
    var to: GameState

    init(from: GameState, to: GameState) {
        self.from = from
        self.to = to
    }
}

