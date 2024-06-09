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
    let randomness: Randomizing
    var buttonPadding = 30.0
    var buttonPaddingLeft = 30.0
    var buttonPaddingRight = 30.0
    var fireButtonEntity: Entity? //HACK
    var firstRowButtonPaddingY = 30.0
    var hyperspaceButtonEntity: Entity? //HACK
    var size: CGSize
    var scaleManager: ScaleManaging
    weak var alertPresenter: AlertPresenting?
    weak var engine: Engine!
    weak var generator: UIImpactFeedbackGenerator?

    init(engine: Engine,
         size: CGSize,
         generator: UIImpactFeedbackGenerator? = nil,
         scaleManager: ScaleManaging = ScaleManager.shared,
         alertPresenter: AlertPresenting,
         randomness: Randomizing = Randomness.shared 
    ) {
        self.scaleManager = scaleManager
        self.alertPresenter = alertPresenter
        buttonPadding *= scaleManager.SCALE_FACTOR
        buttonPaddingLeft *= scaleManager.SCALE_FACTOR
        buttonPaddingRight *= scaleManager.SCALE_FACTOR
        firstRowButtonPaddingY *= scaleManager.SCALE_FACTOR
        self.engine = engine
        self.size = size
        self.generator = generator
        self.randomness = randomness
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
           let window = appDelegate.window {
            buttonPaddingLeft += max(window.safeAreaInsets.left, 10)
            buttonPaddingRight += max(window.safeAreaInsets.right, 10)
            firstRowButtonPaddingY += max(window.safeAreaInsets.bottom, 10)
        }
    }

    func removeEntity(_ entity: Entity) {
        engine.remove(entity: entity)
    }
}
