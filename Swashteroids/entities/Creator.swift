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
    var numTorpedoes = 0
    var buttonPadding = 30.0
    var buttonPaddingLeft = 30.0
    var buttonPaddingRight = 30.0
    var firstRowButtonPaddingY = 30.0

    init(engine: Engine,
         size: CGSize, generator: UIImpactFeedbackGenerator? = nil,
         scaleManager: ScaleManaging = ScaleManager.shared,
         alertPresenter: AlertPresenting) {
        self.scaleManager = scaleManager
        self.alertPresenter = alertPresenter
        buttonPadding *= scaleManager.SCALE_FACTOR
        buttonPaddingLeft *= scaleManager.SCALE_FACTOR
        buttonPaddingRight *= scaleManager.SCALE_FACTOR
        firstRowButtonPaddingY *= scaleManager.SCALE_FACTOR
        self.engine = engine
        self.size = size
        self.generator = generator
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

extension Creator: AlienCreator {
    func createAlien() {
        guard engine.getEntity(named: .ship) != nil else { return }
        guard engine.getEntity(named: "alien") == nil else { return }
        let sprite = SwashSpriteNode(imageNamed: "alien")
        let alien = Entity(named: "alien")
                .add(component: AlienComponent())
                .add(component: CollisionComponent(radius: 25))
                .add(component: GunComponent(offsetX: 21,
                                             offsetY: 0,
                                             minimumShotInterval: 2,
                                             torpedoLifetime: 2,
                                             torpedoColor: .white,
                                             ownerType: .computerOpponent))
                .add(component: FireDownComponent.shared)
                .add(component: PositionComponent(x: -sprite.width/2, y: Double.random(in: 40...(size.height - 40)), z: .asteroids))
                .add(component: VelocityComponent(velocityX: 60, velocityY: 0, wraps: false))
                .add(component: DisplayComponent(sknode: sprite))
        try? engine.add(entity: alien)
    }
}