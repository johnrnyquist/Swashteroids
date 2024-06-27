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
    var from: SwashteroidsState
    var to: SwashteroidsState

    init(from: SwashteroidsState, to: SwashteroidsState) {
        self.from = from
        self.to = to
    }
}

