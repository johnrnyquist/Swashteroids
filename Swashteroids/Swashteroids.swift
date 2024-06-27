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

class SystemsManager {
    init(scene: GameScene, engine: Engine, creatorManager: CreatorsManager, generator: UIImpactFeedbackGenerator) {
        let soundPlayer = scene
        let transition = PlayingTransition(
            hudCreator: creatorManager.hudCreator,
            toggleShipControlsCreator: creatorManager.toggleShipControlsCreator,
            shipControlQuadrantsCreator: creatorManager.shipControlQuadrantsCreator,
            shipButtonControlsCreator: creatorManager.shipButtonControlsCreator)
        let startTransition = StartTransition(engine: engine, generator: generator)
        let gameOverTransition = GameOverTransition(engine: engine, generator: generator)
        let infoViewsTransition = InfoViewsTransition(engine: engine, generator: generator)
        engine
            // preupdate
                .add(system: TimePlayedSystem(), priority: .preUpdate)
                .add(system: GameplayManagerSystem(asteroidCreator: creatorManager.asteroidCreator,
                                                   alienCreator: creatorManager.alienCreator,
                                                   shipCreator: creatorManager.shipCreator,
                                                   size: scene.size,
                                                   scene: scene),
                     priority: .preUpdate)
                .add(system: GameOverSystem(), priority: .preUpdate)
                .add(system: ShipControlsSystem(toggleShipControlsCreator: creatorManager.toggleShipControlsCreator,
                                                shipControlQuadrantsCreator: creatorManager.shipControlQuadrantsCreator,
                                                shipButtonControlsCreator: creatorManager.shipButtonControlsCreator),
                     priority: .preUpdate)
                .add(system: TransitionAppStateSystem(startTransition: startTransition,
                                                      infoViewsTransition: infoViewsTransition,
                                                      playingTransition: transition,
                                                      gameOverTransition: gameOverTransition),
                     priority: .preUpdate)
                // update
                .add(system: LifetimeSystem(), priority: .update)
                .add(system: ReactionTimeSystem(), priority: .update)
                .add(system: PickTargetSystem(), priority: .update)
                .add(system: MoveToTargetSystem(), priority: .update)
                .add(system: ExitScreenSystem(), priority: .update)
                .add(system: AlienFiringSystem(torpedoCreator: creatorManager.torpedoCreator, gameSize: scene.size),
                     priority: .update)
                .add(system: FiringSystem(torpedoCreator: creatorManager.torpedoCreator), priority: .update)
                .add(system: TorpedoAgeSystem(), priority: .update)
                .add(system: DeathThroesSystem(), priority: .update)
                .add(system: HyperspaceJumpSystem(engine: engine), priority: .update)
                .add(system: NacellesSystem(), priority: .update)
                .add(system: HudSystem(powerUpCreator: creatorManager.powerUpCreator), priority: .update)
                .add(system: SplitAsteroidSystem(asteroidCreator: creatorManager.asteroidCreator,
                                                 treasureCreator: creatorManager.treasureCreator),
                     priority: .update)
                // move
                .add(system: AccelerometerSystem(), priority: .move)
                .add(system: FlipSystem(), priority: .move)
                .add(system: LeftSystem(), priority: .move)
                .add(system: MovementSystem(gameSize: scene.size), priority: .move)
                .add(system: RightSystem(), priority: .move)
                .add(system: ThrustSystem(), priority: .move)
                // resolve collisions
                .add(system: CollisionSystem(shipCreator: creatorManager.shipCreator,
                                             asteroidCreator: creatorManager.asteroidCreator,
                                             shipButtonControlsCreator: creatorManager.shipButtonControlsCreator,
                                             size: scene.size),
                     priority: .resolveCollisions)
                // animate
                .add(system: AnimationSystem(), priority: .animate)
                // render
                .add(system: AudioSystem(soundPlayer: soundPlayer), priority: .render)
                .add(system: RepeatingAudioSystem(), priority: .render)
                .add(system: RenderSystem(scene: scene), priority: .render)
    }
}

final class Swashteroids: NSObject {
    lazy private var tickEngineListener = Listener(engine.update)
    let motionManager: CMMotionManager? = CMMotionManager()
    private let generator = UIImpactFeedbackGenerator(style: .heavy)
    private var tickProvider: TickProvider?
    private(set) var engine = Engine()
    private(set) var inputComponent = InputComponent.shared
    private(set) var manager_creators: CreatorsManager!
    private(set) var manager_systems: SystemsManager!
    private(set) var orientation = 1.0
    private(set) weak var scene: GameScene!
    weak var alertPresenter: AlertPresenting!

    init(scene: GameScene, alertPresenter: AlertPresenting, seed: Int = 0) {
        self.scene = scene
        self.alertPresenter = alertPresenter
        if seed == 0 {
            Randomness.initialize(with: Int(Date().timeIntervalSince1970))
        } else {
            Randomness.initialize(with: seed)
        }
        orientation = UIDevice.current.orientation == .landscapeRight ? -1.0 : 1.0
        super.init()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(orientationChanged),
                                               name: UIDevice.orientationDidChangeNotification, object: nil)
        createInitialEntities(scene: scene)
        manager_creators = CreatorsManager(engine: engine,
                                           gameSize: scene.size,
                                           alertPresenter: alertPresenter,
                                           generator: generator)
        manager_systems = SystemsManager(scene: scene, engine: engine, creatorManager: manager_creators, generator: generator)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func createInitialEntities(scene: GameScene) {
        let allSoundsEntity = Entity(named: .allSounds)
                .add(component: AllSoundsComponent.shared)
        let appStateEntity = Entity(named: .appState)
                .add(component: SwashteroidsStateComponent(config: SwashteroidsConfig(gameSize: scene.size)))
                .add(component: TransitionAppStateComponent(from: .start, to: .start))
                .add(component: TimePlayedComponent())
        let inputEntity = Entity(named: .input)
                .add(component: InputComponent.shared)
        engine.add(entity: allSoundsEntity)
        engine.add(entity: appStateEntity)
        engine.add(entity: inputEntity)
    }

    func usingGameController() {
        engine.appStateEntity.add(component: ChangeShipControlsStateComponent(to: .usingGameController))
    }

    func usingScreenControls() {
        engine.appStateEntity.add(component: ChangeShipControlsStateComponent(to: .usingScreenControls))
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

    var currentTime = 0.0

    func dispatchTick(_ currentTime: TimeInterval) {
        self.currentTime = currentTime
        tickProvider?.dispatchTick(currentTime)
    }

    @objc func orientationChanged(_ notification: Notification) {
        orientation = UIDevice.current.orientation == .landscapeRight ? -1.0 : 1.0
    }
}
