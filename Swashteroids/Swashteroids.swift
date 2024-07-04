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
import GameController

class SystemsManager {
    private(set) var transitionAppStateSystem: TransitionAppStateSystem
    
    init(scene: GameScene,
         engine: Engine,
         creatorManager: CreatorsManager,
         generator: UIImpactFeedbackGenerator,
         alertPresenter: PauseAlertPresenting,
         touchManager: TouchManager) {
        let soundPlayer = scene
        let transition = PlayingTransition(
            hudCreator: creatorManager.hudCreator,
            toggleShipControlsCreator: creatorManager.toggleShipControlsCreator,
            shipControlQuadrantsCreator: creatorManager.shipControlQuadrantsCreator,
            shipButtonControlsCreator: creatorManager.shipButtonControlsCreator)
        let startTransition = StartTransition(engine: engine, startButtonsCreator: creatorManager.startButtonsCreator)
        let gameOverTransition = GameOverTransition(engine: engine, alert: alertPresenter, generator: generator)
        let infoViewsTransition = InfoViewsTransition(engine: engine, generator: generator)
        transitionAppStateSystem = TransitionAppStateSystem(startTransition: startTransition,
                                                            infoViewsTransition: infoViewsTransition,
                                                            playingTransition: transition,
                                                            gameOverTransition: gameOverTransition)
        engine
            // preupdate
                .add(system: TouchedButtonSystem(touchManager: touchManager), priority: .preUpdate)
                .add(system: TouchedQuadrantSystem(touchManager: touchManager), priority: .preUpdate)
                .add(system: AlertPresentingSystem(alertPresenting: alertPresenter), priority: .preUpdate)
                .add(system: HyperspaceJumpSystem(engine: engine), priority: .preUpdate)
                .add(system: FiringSystem(torpedoCreator: creatorManager.torpedoCreator), priority: .preUpdate)
                .add(system: FlipSystem(), priority: .preUpdate)
                .add(system: LeftSystem(), priority: .preUpdate)
                .add(system: RightSystem(), priority: .preUpdate)
                .add(system: ThrustSystem(), priority: .preUpdate)
                .add(system: TimePlayedSystem(), priority: .preUpdate)
                .add(system: GameplayManagerSystem(asteroidCreator: creatorManager.asteroidCreator,
                                                   alienCreator: creatorManager.alienCreator,
                                                   shipCreator: creatorManager.shipCreator,
                                                   scene: scene),
                     priority: .preUpdate)
                .add(system: GameOverSystem(), priority: .preUpdate)
                .add(system: ShipControlsSystem(toggleShipControlsCreator: creatorManager.toggleShipControlsCreator,
                                                shipControlQuadrantsCreator: creatorManager.shipControlQuadrantsCreator,
                                                shipButtonControlsCreator: creatorManager.shipButtonControlsCreator,
                                                startButtonsCreator: creatorManager.startButtonsCreator),
                     priority: .update)
                .add(system: transitionAppStateSystem,
                     priority: .preUpdate)
                // update
                .add(system: AlienAppearancesSystem(alienCreator: creatorManager.alienCreator), priority: .update)
                .add(system: LifetimeSystem(), priority: .update)
                .add(system: ReactionTimeSystem(), priority: .update)
                .add(system: PickTargetSystem(), priority: .update)
                .add(system: MoveToTargetSystem(), priority: .update)
                .add(system: ExitScreenSystem(), priority: .update)
                .add(system: AlienFiringSystem(torpedoCreator: creatorManager.torpedoCreator, gameSize: scene.size),
                     priority: .update)
                .add(system: TorpedoAgeSystem(), priority: .update)
                .add(system: DeathThroesSystem(), priority: .update)
                .add(system: NacellesSystem(), priority: .update)
                .add(system: HudSystem(powerUpCreator: creatorManager.powerUpCreator), priority: .update)
                .add(system: SplitAsteroidSystem(asteroidCreator: creatorManager.asteroidCreator,
                                                 treasureCreator: creatorManager.treasureCreator),
                     priority: .update)
                .add(system: LevelManagementSystem(asteroidCreator: creatorManager.asteroidCreator, scene: scene),
                     priority: .update)
                // move
                .add(system: AccelerometerSystem(), priority: .move)
                .add(system: MovementSystem(gameSize: scene.size), priority: .move)
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
    public var gamePadManager: GamePadInputManager? {
        didSet {
            manager_systems.transitionAppStateSystem.gamePadManager = gamePadManager //HACK
        }
    }
    lazy private var tickEngineListener = Listener(engine.update)
    let motionManager: CMMotionManager? = CMMotionManager()
    private let generator = UIImpactFeedbackGenerator(style: .heavy)
    private var tickProvider: TickProvider?
    private(set) var engine = Engine()
    private(set) var accelerometerComponent = AccelerometerComponent.shared // using in SKSceneDelegate extension
    private(set) var manager_creators: CreatorsManager!
    private(set) var manager_systems: SystemsManager!
    private(set) var orientation = 1.0
    private(set) weak var scene: GameScene!
    weak var alertPresenter: PauseAlertPresenting!
    public var gameState: GameState {
        gameStateComponent.gameState
    }
    public var gameStateComponent: GameStateComponent {
        engine.gameStateComponent
    }
    var touchManager: TouchManager

    init(scene: GameScene, alertPresenter: PauseAlertPresenting, seed: Int = 0, touchManager: TouchManager) {
        self.scene = scene
        self.touchManager = touchManager
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
                                           generator: generator,
                                           scene: scene)
        manager_systems = SystemsManager(scene: scene,
                                         engine: engine,
                                         creatorManager: manager_creators,
                                         generator: generator,
                                         alertPresenter: alertPresenter,
                                         touchManager: touchManager)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func createInitialEntities(scene: GameScene) {
        let allSoundsEntity = Entity(named: .allSounds)
                .add(component: AllSoundsComponent.shared)
        let appStateEntity = Entity(named: .appState)
                .add(component: GameStateComponent(config: GameConfig(gameSize: scene.size)))
                .add(component: ChangeGameStateComponent(from: .start, to: .start))
                .add(component: TimePlayedComponent())
                .add(component: AlienAppearancesComponent.shared) //HACK
//        let inputEntity = Entity(named: .input)
//                .add(component: InputComponent.shared)
        engine.add(entity: allSoundsEntity)
        engine.add(entity: appStateEntity)
//        engine.add(entity: inputEntity)
    }

    func usingGamePad() {
        if GCController.isGameControllerConnected() {
            engine.gameStateEntity.add(component: ChangeShipControlsStateComponent(to: .usingGameController))
        }
    }

    func usingScreenControls() {
        engine.gameStateEntity.add(component: ChangeShipControlsStateComponent(to: .usingScreenControls))
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
