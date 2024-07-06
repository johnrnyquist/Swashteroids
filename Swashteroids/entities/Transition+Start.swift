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
    let startButtonsCreator: StartButtonsCreatorUseCase

    init(engine: Engine, startButtonsCreator: StartButtonsCreatorUseCase) {
        self.engine = engine
        self.startButtonsCreator = startButtonsCreator
    }

    func fromStartScreen() {
        startButtonsCreator.removeStart()
    }

    /// The start screen is not an entity, but composed of entities.  It is the first screen the user sees.
    func toStartScreen() {
        startButtonsCreator.createStart()
        startButtonsCreator.createStartButtons()
    }
}
