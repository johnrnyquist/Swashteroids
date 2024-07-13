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
    //HACK: This is a hack to allow the gamepad to be used in the game. It is not a great solution.
    func setGamepadInputManager(_ mgr: GamepadInputManager?) {
        manager_systems.transitionAppStateSystem.gamepadManager = mgr
        if let _ = mgr?.pad {
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

    init(config: GameConfig, scene: GameScene, alertPresenter: PauseAlertPresenting, seed: Int = 0, touchManager: TouchManager) {
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
                .add(component: GameStateComponent(config: config))
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
