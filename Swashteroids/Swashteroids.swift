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
    let motionManager: CMMotionManager? = CMMotionManager()
    private let alertPresenter: AlertPresenting
    private let generator = UIImpactFeedbackGenerator(style: .heavy)
    private var creator: Creator
    private var tickEngineListener: Listener
    private var tickProvider: TickProvider?
    private var transition: Transition
    private(set) var engine: Engine
    private(set) var inputComponent = InputComponent.shared
    private(set) var orientation = 1.0
    private(set) var scene: GameScene
    var appStateComponent: AppStateComponent
    let randomness: Randomness

    init(scene: GameScene, alertPresenter: AlertPresenting, seed: Int = 0) {
        self.scene = scene
        self.alertPresenter = alertPresenter
        if seed == 0 {
            randomness = Randomness(seed: Int(Date().timeIntervalSince1970))
        } else {
            randomness = Randomness(seed: seed)
        }
        appStateComponent = AppStateComponent(gameSize: scene.size,
                                              numShips: 3,
                                              level: 0,
                                              score: 0,
                                              appState: .initial,
                                              shipControlsState: .showingButtons,
                                              randomness: randomness)
        engine = Engine()
        tickEngineListener = Listener(engine.update)
        creator = Creator(engine: engine, size: scene.size, appState: appStateComponent, generator: generator, alertPresenter: alertPresenter, randomness: randomness)
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
        let allSoundsEntity = Entity(named: .allSounds)
                .add(component: AllSoundsComponent.shared)
        try? engine.add(entity: allSoundsEntity)
        let appStateEntity = Entity(named: .appState)
                .add(component: appStateComponent)
                .add(component: TransitionAppStateComponent(from: .initial, to: .start))
                .add(component: TimePlayedComponent())
        try? engine.add(entity: appStateEntity)
        // Add the input entity
        let inputEntity = Entity(named: .input)
                .add(component: InputComponent.shared)
        try? engine.add(entity: inputEntity)
    }

    private func createSystems(scene: GameScene) {
        let gameSize = scene.size
        let soundPlayer = scene
        let container = scene
        engine
            // preupdate
                .add(system: TimePlayedSystem(), priority: .preUpdate)
                .add(system: GameplayManagerSystem(creator: creator, size: gameSize, scene: scene, randomness: randomness),
                     priority: .preUpdate)
                .add(system: GameOverSystem(), priority: .preUpdate)
                .add(system: ShipControlsSystem(creator: creator), priority: .preUpdate)
                .add(system: TransitionAppStateSystem(transition: transition), priority: .preUpdate)
                // move
                .add(system: AccelerometerSystem(), priority: .move)
                .add(system: FlipSystem(), priority: .move)
                .add(system: LeftSystem(), priority: .move)
                .add(system: MovementSystem(gameSize: gameSize), priority: .move)
                .add(system: RightSystem(), priority: .move)
                .add(system: ThrustSystem(), priority: .move)
                // resolve collisions
                .add(system: CollisionSystem(creator: creator, size: gameSize, randomness: randomness),
                     priority: .resolveCollisions)
                // animate
                .add(system: AnimationSystem(), priority: .animate)
                // update
                .add(system: AlienSoldierSystem(), priority: .update)
                .add(system: AlienWorkerSystem(randomness: randomness), priority: .update)
                .add(system: AlienFiringSystem(creator: creator, gameSize: gameSize), priority: .update)
                .add(system: FiringSystem(creator: creator), priority: .update)
                .add(system: TorpedoAgeSystem(), priority: .update)
                .add(system: DeathThroesSystem(), priority: .update)
                .add(system: HyperspaceJumpSystem(engine: engine, creator: creator), priority: .update)
                .add(system: NacellesSystem(), priority: .update)
                .add(system: HudSystem(creator: creator), priority: .update)
                // render
                .add(system: AudioSystem(soundPlayer: soundPlayer), priority: .render)
                .add(system: RepeatingAudioSystem(), priority: .render)
                .add(system: RenderSystem(container: container), priority: .render)
    }

    func start() {
        motionManager?.startAccelerometerUpdates()
        tickProvider = TickProvider()
        tickProvider?.add(tickEngineListener) // Then engine listens for ticks
        tickProvider?.start()
    }

    func stop() {
        tickProvider?.stop()
        tickProvider?.remove(tickEngineListener)
        tickProvider = nil
        motionManager?.stopAccelerometerUpdates()
    }

    func dispatchTick(_ currentTime: TimeInterval) {
        tickProvider?.dispatchTick(currentTime)
    }

    @objc func orientationChanged(_ notification: Notification) {
        orientation = UIDevice.current.orientation == .landscapeRight ? -1.0 : 1.0
    }
}
