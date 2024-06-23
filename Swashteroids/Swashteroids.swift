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
    deinit {
        print("Swashteroids deinit")
        NotificationCenter.default.removeObserver(self)
    }

    let motionManager: CMMotionManager? = CMMotionManager()
    private let generator = UIImpactFeedbackGenerator(style: .heavy)
    private var tickEngineListener: Listener
    private var tickProvider: TickProvider?
    private(set) var engine: Engine
    private(set) var inputComponent = InputComponent.shared
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
        engine = Engine()
        tickEngineListener = Listener(engine.update)
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
        let appStateComponent = AppStateComponent(gameConfig: GameConfig(gameSize: scene.size))
        let appStateEntity = Entity(named: .appState)
                .add(component: appStateComponent)
                .add(component: TransitionAppStateComponent(from: .start, to: .start))
                .add(component: TimePlayedComponent())
        try? engine.add(entity: appStateEntity)
        // Add the input entity
        let inputEntity = Entity(named: .input)
                .add(component: InputComponent.shared)
        try? engine.add(entity: inputEntity)
    }

    func usingGameController() {
        engine.appStateEntity.add(component: ChangeShipControlsStateComponent(to: .usingGameController))
    }

    func usingScreenControls() {
        engine.appStateEntity.add(component: ChangeShipControlsStateComponent(to: .usingScreenControls))
    }

    private func createSystems(scene: GameScene) {
        let gameSize = scene.size
        let soundPlayer = scene
        let torpedoCreator = TorpedoCreator(engine: engine)
        let treasureCreator = TreasureCreator(engine: engine)
        let powerUpCreator = PowerUpCreator(engine: engine, size: gameSize)
        let asteroidCreator = AsteroidCreator(engine: engine)
        let alienCreator = AlienCreator(engine: engine, size: gameSize)
        let shipCreator = ShipCreator(engine: engine, size: gameSize)
        let toggleShipControlsCreator = ToggleShipControlsCreator(engine: engine, size: gameSize, generator: generator)
        let shipControlQuadrantsCreator = ShipQuadrantsControlsCreator(engine: engine, size: gameSize, generator: generator)
        let shipButtonControlsCreator = ShipButtonControlsCreator(engine: engine, size: gameSize, generator: generator)
        let transition = PlayingTransition(
            hudCreator: HudCreator(engine: engine, alertPresenter: alertPresenter),
            toggleShipControlsCreator: toggleShipControlsCreator,
            shipControlQuadrantsCreator: shipControlQuadrantsCreator,
            shipButtonControlsCreator: shipButtonControlsCreator)
        let startTransition = StartTransition(engine: engine, generator: generator)
        let gameOverTransition = GameOverTransition(engine: engine, generator: generator)
        let infoViewsTransition = InfoViewsTransition(engine: engine, generator: generator)
        engine
            // preupdate
                .add(system: TimePlayedSystem(), priority: .preUpdate)
                .add(system: GameplayManagerSystem(asteroidCreator: asteroidCreator,
                                                   alienCreator: alienCreator,
                                                   shipCreator: shipCreator,
                                                   size: gameSize,
                                                   scene: scene),
                     priority: .preUpdate)
                .add(system: GameOverSystem(), priority: .preUpdate)
                .add(system: ShipControlsSystem(toggleShipControlsCreator: toggleShipControlsCreator,
                                                shipControlQuadrantsCreator: shipControlQuadrantsCreator,
                                                shipButtonControlsCreator: shipButtonControlsCreator),
                     priority: .preUpdate)
                .add(system: TransitionAppStateSystem(startTransition: startTransition,
                                                      infoViewsTransition: infoViewsTransition,
                                                      playingTransition: transition,
                                                      gameOverTransition: gameOverTransition),
                     priority: .preUpdate)
                // update
                .add(system: LifetimeSystem(), priority: .update)
                .add(system: ReactionTimeSystem(), priority: .update)
                .add(system: MakeDecisionSystem(), priority: .update)
                .add(system: PickTargetSystem(), priority: .update)
                .add(system: MoveToTargetSystem(), priority: .update)
                .add(system: ExitScreenSystem(), priority: .update)
                .add(system: AlienFiringSystem(torpedoCreator: torpedoCreator, gameSize: gameSize), priority: .update)
                .add(system: FiringSystem(torpedoCreator: torpedoCreator), priority: .update)
                .add(system: TorpedoAgeSystem(), priority: .update)
                .add(system: DeathThroesSystem(), priority: .update)
                .add(system: HyperspaceJumpSystem(engine: engine), priority: .update)
                .add(system: NacellesSystem(), priority: .update)
                .add(system: HudSystem(powerUpCreator: powerUpCreator), priority: .update)
                .add(system: SplitAsteroidSystem(asteroidCreator: asteroidCreator,
                                                 treasureCreator: treasureCreator),
                     priority: .update)
                // move
                .add(system: AccelerometerSystem(), priority: .move)
                .add(system: FlipSystem(), priority: .move)
                .add(system: LeftSystem(), priority: .move)
                .add(system: MovementSystem(gameSize: gameSize), priority: .move)
                .add(system: RightSystem(), priority: .move)
                .add(system: ThrustSystem(), priority: .move)
                // resolve collisions
                .add(system: CollisionSystem(shipCreator: shipCreator,
                                             asteroidCreator: asteroidCreator,
                                             shipButtonControlsCreator: shipButtonControlsCreator,
                                             size: gameSize),
                     priority: .resolveCollisions)
                // animate
                .add(system: AnimationSystem(), priority: .animate)
                // render
                .add(system: AudioSystem(soundPlayer: soundPlayer), priority: .render)
                .add(system: RepeatingAudioSystem(), priority: .render)
                .add(system: RenderSystem(scene: scene), priority: .render)
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
