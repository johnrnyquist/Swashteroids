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

/// Creator is a bunch of convenience methods that create and configure entities, then adds them to its engine.
class Creator {
    let generator = UIImpactFeedbackGenerator(style: .heavy)
    var appStateEntity: Entity!
    var engine: Engine
    var inputComponent: InputComponent
    var numAsteroids = 0
    var numTorpedoes = 0
    var scene: SKScene
    var size: CGSize

    init(engine: Engine, appStateEntity: Entity, inputComponent: InputComponent, scene: SKScene, size: CGSize) {
        self.engine = engine
        self.inputComponent = inputComponent
        self.size = size
        self.scene = scene
        self.appStateEntity = appStateEntity
    }

    func destroyEntity(_ entity: Entity) {
        engine.removeEntity(entity: entity)
    }
}
