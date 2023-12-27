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
import CoreMotion

final class Swashteroids: NSObject {
    private let generator = UIImpactFeedbackGenerator(style: .heavy)
    let motionManager = CMMotionManager()
    var orientation = 1.0
    var inputComponent = InputComponent.shared
    var scene: GameScene
    private var creator: Creator
    private var transition: Transition
    private var engine: Engine
    private var tickProvider: FrameTickProvider?
    private var tickEngineListener: Listener
    var alertPresenter: AlertPresenter

    init(scene: GameScene, alertPresenter: AlertPresenter) {
        self.scene = scene
        self.alertPresenter = alertPresenter
        engine = Engine()
        tickEngineListener = Listener(engine.update)
        creator = Creator(engine: engine, size: scene.size, generator: generator, alertPresenter: alertPresenter)
        transition = Transition(engine: engine, creator: creator, generator: generator)
        orientation = UIDevice.current.orientation == .landscapeRight ? -1.0 : 1.0
        super.init()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(orientationChanged),
                                               name: UIDevice.orientationDidChangeNotification, object: nil)
        createInitialEntities(scene: scene)
        createSystems(scene: scene)
    }

    private func createInitialEntities(scene: GameScene) { // Add the all sounds entity
        let allSoundsEntity = Entity(name: .allSounds)
                .add(component: AllSoundsComponent.shared)
        try? engine.addEntity(entity: allSoundsEntity)
        // Add the app state entity
        let appStateComponent = AppStateComponent(size: scene.size,
                                                  ships: 3,
                                                  level: 0,
                                                  score: 0,
                                                  appState: .start,
                                                  shipControlsState: .showingButtons)
        let appStateEntity = Entity(name: .appState)
                .add(component: appStateComponent)
                .add(component: TransitionAppStateComponent(to: .start))
        try? engine.addEntity(entity: appStateEntity)
        // Add the input entity
        let inputEntity = Entity(name: .input)
                .add(component: InputComponent.shared)
        try? engine.addEntity(entity: inputEntity)
    }

    private func createSystems(scene: GameScene) {
        engine
            // preupdate
                .addSystem(system: GameManagerSystem(creator: creator, size: scene.size, scene: scene), priority: .preUpdate)
                .addSystem(system: GameOverSystem(), priority: .preUpdate)
                .addSystem(system: ShipControlsSystem(creator: creator, scene: scene, game: self), priority: .preUpdate)
                .addSystem(system: TransitionAppStateSystem(transition: transition), priority: .preUpdate)
                // move
                .addSystem(system: AccelerometerSystem(), priority: .move)
                .addSystem(system: FlipSystem(), priority: .move)
                .addSystem(system: LeftSystem(), priority: .move)
                .addSystem(system: MovementSystem(size: scene.size), priority: .move)
                .addSystem(system: RightSystem(), priority: .move)
                .addSystem(system: ThrustSystem(), priority: .move)
                // resolve collisions
                .addSystem(system: CollisionSystem(creator, size: scene.size), priority: .resolveCollisions)
                // animate
                .addSystem(system: AnimationSystem(), priority: .animate)
                .addSystem(system: HudSystem(), priority: .animate)
                // update
                .addSystem(system: TorpedoAgeSystem(), priority: .update)
                .addSystem(system: DeathThroesSystem(), priority: .update)
                .addSystem(system: FiringSystem(creator: creator), priority: .update)
                .addSystem(system: HyperspaceSystem(), priority: .update)
                .addSystem(system: NacelleSystem(), priority: .update)
                // render
                .addSystem(system: AudioSystem(scene: scene), priority: .render)
                .addSystem(system: RepeatingAudioSystem(scene: scene), priority: .render)
                .addSystem(system: RenderSystem(container: scene), priority: .render)
    }

    func start() {
        motionManager.startAccelerometerUpdates()
        tickProvider = FrameTickProvider()
        tickProvider?.add(tickEngineListener) // Then engine listens for ticks
        tickProvider?.start()
    }

    func stop() {
        tickProvider?.stop()
        tickProvider?.remove(tickEngineListener)
        tickProvider = nil
        motionManager.stopAccelerometerUpdates()
    }

    func dispatchTick() {
        tickProvider?.dispatchTick()
    }

    @objc func orientationChanged(_ notification: Notification) {
        orientation = UIDevice.current.orientation == .landscapeRight ? -1.0 : 1.0
    }
}
