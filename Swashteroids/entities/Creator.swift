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
    var alertPresenter: AlertPresenting?
    var engine: Engine
    var size: CGSize
    var generator: UIImpactFeedbackGenerator?
    let scaleManager: ScaleManaging
    var numAsteroids = 0
    var numAliens = 0
    var numTreasures = 0
    var buttonPadding = 30.0
    var buttonPaddingLeft = 30.0
    var buttonPaddingRight = 30.0
    var firstRowButtonPaddingY = 30.0
    var fireButtonEntity: Entity? //HACK
    var hyperspaceButtonEntity: Entity? //HACK
    let randomness: Randomness
    let appState: AppStateComponent

    init(engine: Engine, size: CGSize, appState: AppStateComponent, generator: UIImpactFeedbackGenerator? = nil, scaleManager: ScaleManaging = ScaleManager.shared, alertPresenter: AlertPresenting, randomness: Randomness) {
        self.scaleManager = scaleManager
        self.alertPresenter = alertPresenter
        buttonPadding *= scaleManager.SCALE_FACTOR
        buttonPaddingLeft *= scaleManager.SCALE_FACTOR
        buttonPaddingRight *= scaleManager.SCALE_FACTOR
        firstRowButtonPaddingY *= scaleManager.SCALE_FACTOR
        self.engine = engine
        self.size = size
        self.appState = appState
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

    func addEmitter(colored color: UIColor, on sknode: SKNode) {
        if let emitter = SKEmitterNode(fileNamed: "fireflies_mod.sks") {
            // emitter.setScale(1.0 * scaleManager.SCALE_FACTOR)
            // let colorRamp: [UIColor] = [color.lighter(by: 30.0).shiftHue(by: 10.0)]
            let colorRamp: [UIColor] = [color.shiftHue(by: 5.0)]
            let keyTimes: [NSNumber] = [1.0]
            let colorSequence = SKKeyframeSequence(keyframeValues: colorRamp, times: keyTimes)
            emitter.particleColorSequence = colorSequence
            sknode.addChild(emitter)
        }
    }
}
