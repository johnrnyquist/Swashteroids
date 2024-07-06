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

final class ChangeGameStateComponent: Component {
    var from: GameScreen
    var to: GameScreen

    init(from: GameScreen, to: GameScreen) {
        self.from = from
        self.to = to
    }
}

