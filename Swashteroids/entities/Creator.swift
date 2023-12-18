//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import SpriteKit
import Swash

/// Creator contains a number of convenience methods that create and configure entities, then adds them to its engine.
class Creator {
    var engine: Engine
    var size: CGSize
    var generator: UIImpactFeedbackGenerator?
    var numAsteroids = 0
    var numTorpedoes = 0

    init(engine: Engine, size: CGSize, generator: UIImpactFeedbackGenerator? = nil) {
        self.engine = engine
        self.size = size
        self.generator = generator
    }

    func removeEntity(_ entity: Entity) {
        engine.removeEntity(entity: entity)
    }
}
