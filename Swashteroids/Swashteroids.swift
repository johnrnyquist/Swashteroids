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
         alertPresenter: PauseAlertPresenting,
         touchManager: TouchManager) {
        let transition = PlayingTransition(
            hudCreator: creatorManager.hudCreator,
            toggleShipControlsCreator: creatorManager.toggleShipControlsCreator,
            shipControlQuadrantsCreator: creatorManager.shipControlQuadrantsCreator,
            shipButtonControlsCreator: creatorManager.shipButtonControlsCreator)
        let startTransition = StartTransition(engine: engine, startButtonsCreator: creatorManager.startButtonsCreator)
        let gameOverTransition = GameOverTransition(engine: engine, alert: alertPresenter)
        let infoViewsTransition = InfoViewsTransition(engine: engine)
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
                                                   playerCreator: creatorManager.shipCreator,
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
                .add(system: AudioSystem(), priority: .render)
                .add(system: RepeatingAudioSystem(), priority: .render)
                .add(system: RenderSystem(scene: scene), priority: .render)
    }
}

final class Swashteroids: NSObject {
    //HACK: This is a hack to allow the gamepad to be used in the game. It is not a great solution.
    func setGamepadInputManager(_ pad: GamepadInputManager?) {
        manager_systems.transitionAppStateSystem.gamepadManager = pad
        if let _ = pad {
            usingGamepad()
        } else {
            usingScreenControls()
        }
    }

    lazy private var tickEngineListener = Listener(engine.update)
    let accelerometerComponent = AccelerometerComponent.shared // using in SKSceneDelegate extension
    let engine = Engine()
    let manager_motion: CMMotionManager? = CMMotionManager()
    let manager_touch: TouchManager
    private let manager_creators: CreatorsManager!
    private let manager_systems: SystemsManager!
    private(set) var tickProvider: TickProvider?
    private(set) var orientation = 1.0
    private(set) weak var scene: GameScene!
    weak var alertPresenter: PauseAlertPresenting!
    public var gameScreen: GameScreen {
        gameStateComponent.gameScreen
    }
    public var gameStateComponent: GameStateComponent {
        engine.gameStateComponent
    }

    init(scene: GameScene, alertPresenter: PauseAlertPresenting, seed: Int = 0, touchManager: TouchManager) {
        self.scene = scene
        self.manager_touch = touchManager
        self.alertPresenter = alertPresenter
        if seed == 0 {
            Randomness.initialize(with: Int(Date().timeIntervalSince1970))
        } else {
            Randomness.initialize(with: seed)
        }
        orientation = UIDevice.current.orientation == .landscapeRight ? -1.0 : 1.0
        let appStateEntity = Entity(named: .appState)
                .add(component: GameStateComponent(config: GameConfig(gameSize: scene.size)))
                .add(component: ChangeGameStateComponent(from: .start, to: .start))
                .add(component: TimePlayedComponent())
                .add(component: AlienAppearancesComponent.shared) //HACK: find a better place for this
        engine.add(entity: appStateEntity)
        manager_creators = CreatorsManager(engine: engine,
                                           gameSize: scene.size,
                                           alertPresenter: alertPresenter,
                                           scene: scene)
        manager_systems = SystemsManager(scene: scene,
                                         engine: engine,
                                         creatorManager: manager_creators,
                                         alertPresenter: alertPresenter,
                                         touchManager: touchManager)
        super.init()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(orientationChanged),
                                               name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func usingGamepad() {
        engine.appStateEntity.add(component: ChangeShipControlsStateComponent(to: .usingGamepad))
    }

    private func usingScreenControls() {
        engine.appStateEntity.add(component: ChangeShipControlsStateComponent(to: .usingScreenControls))
    }

    func start() {
        manager_motion?.startAccelerometerUpdates()
        tickProvider = TickProvider()
        tickProvider?.add(tickEngineListener) // Then engine listens for ticks
        tickProvider?.start()
    }

    func stop() {
        tickProvider?.stop()
        tickProvider?.remove(tickEngineListener)
        tickProvider = nil
        manager_motion?.stopAccelerometerUpdates()
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
