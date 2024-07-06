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

class StartTransition: StartUseCase {
    let engine: Engine
    let startScreenCreator: StartScreenCreatorUseCase

    init(engine: Engine, startScreenCreator: StartScreenCreatorUseCase) {
        self.engine = engine
        self.startScreenCreator = startScreenCreator
    }

    func fromStartScreen() {
        startScreenCreator.removeStartScreen()
    }

    /// The start screen is not an entity, but composed of entities.  It is the first screen the user sees.
    func toStartScreen() {
        startScreenCreator.createStartScreen()
    }
}
