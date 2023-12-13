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
    /// For haptic feedback
    let generator = UIImpactFeedbackGenerator(style: .heavy)
    /// For accelerometer
    let motionManager = CMMotionManager()
    /// For rotation of the device
    var orientation = 1.0
    /// For capturing input 
    var inputComponent = InputComponent.shared
    /// A SpriteKit SKScene subclass to display the game
    var scene: GameScene
    /// Used to create and configure Entity instances
    var creator: Creator
    /// Used to transition between game states
    var transtition: Transition
    /// Drives the game
    private var engine: Engine
    /// Drives the engine
    private var tickProvider: FrameTickProvider

    init(scene: GameScene) {
        self.scene = scene
        engine = Engine()
        tickProvider = FrameTickProvider()
        creator = Creator(engine: engine, size: scene.size, generator: generator)
        transtition = Transition(engine: engine, creator: creator, generator: generator)
        orientation = UIDevice.current.orientation == .landscapeRight ? -1.0 : 1.0
        super.init()
        //
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(orientationChanged),
                                               name: UIDevice.orientationDidChangeNotification, object: nil)
        // Add the all sounds entity
        let allSoundsEntity = Entity(name: .allSounds)
                .add(component: AllSoundsComponent.shared)
        try? engine.addEntity(entity: allSoundsEntity)
        // Add the app state entity
        let appStateComponent = AppStateComponent(size: scene.size)
        let appStateEntity = Entity(name: .appState)
                .add(component: appStateComponent)
                .add(component: TransitionAppStateComponent(to: .initialize))
        try? engine.addEntity(entity: appStateEntity)
        // Add the input entity
        let inputEntity = Entity(name: .input)
                .add(component: InputComponent.shared)
        try? engine.addEntity(entity: inputEntity)
        // Add the systems to the engine. These are what drive the functionality of the game.
        engine
            // preupdate
                .addSystem(system: GameManagerSystem(creator: creator, size: scene.size, scene: scene), priority: .preUpdate)
                .addSystem(system: TransitionAppStateSystem(transition: transtition), priority: .preUpdate)
                .addSystem(system: ShipControlsSystem(creator: creator, scene: scene, game: self), priority: .preUpdate)
                .addSystem(system: GameOverSystem(), priority: .preUpdate)
                // move
                .addSystem(system: AccelerometerSystem(), priority: .move)
                .addSystem(system: FlipSystem(), priority: .move)
                .addSystem(system: ThrustSystem(), priority: .move)
                .addSystem(system: LeftSystem(), priority: .move)
                .addSystem(system: RightSystem(), priority: .move)
                .addSystem(system: MovementSystem(size: scene.size), priority: .move)
                // resolve collisions
                .addSystem(system: CollisionSystem(creator), priority: .resolveCollisions)
                // animate
                .addSystem(system: AnimationSystem(), priority: .animate)
                .addSystem(system: HudSystem(), priority: .animate)
                // update
                .addSystem(system: BulletAgeSystem(), priority: .update)
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
        tickProvider.add(Listener(engine.update)) // Then engine listens for ticks
        tickProvider.start()
    }

    func dispatchTick() {
        tickProvider.dispatchTick()
    }

    @objc func orientationChanged(_ notification: Notification) {
        orientation = UIDevice.current.orientation == .landscapeRight ? -1.0 : 1.0
    }
}
