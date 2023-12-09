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
    let generator = UIImpactFeedbackGenerator(style: .heavy)
    var engine: Engine
    var numAsteroids = 0
    var numTorpedoes = 0
    var scene: SKScene
    var size: CGSize

    init(engine: Engine, scene: SKScene) { //HACK: sound is a hack
        self.engine = engine
        self.size = scene.size
        self.scene = scene
    }

    func removeEntity(_ entity: Entity) {
        engine.removeEntity(entity: entity)
    }
}
