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

final class Swashteroids {
    //
    /// A SpriteKit SKScene subclass
    private var scene: GameScene
    //
    /// Drives the game
    private var engine: Engine
    //
    /// Drives the engine
    private var tickProvider: FrameTickProvider
    //
    /// Used to create and configure Entity instances
    var creator: Creator

    init(scene: GameScene) {
        self.scene = scene
        engine = Engine()
        tickProvider = FrameTickProvider()
        creator = Creator(engine: engine, scene: scene) //HACK
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
                .addSystem(system: TransitionAppStateSystem(creator: creator), priority: .preUpdate)
                .addSystem(system: ShipControlsSystem(scene: scene), priority: .preUpdate)
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
                .addSystem(system: HyperSpaceSystem(), priority: .update)
                .addSystem(system: NacelleSystem(), priority: .update)
                // render
                .addSystem(system: AudioSystem(scene: scene), priority: .render)
                .addSystem(system: RepeatingAudioSystem(scene: scene), priority: .render)
                .addSystem(system: RenderSystem(container: scene), priority: .render)
    }

    func start() {
        tickProvider.add(Listener(engine.update)) // Then engine listens for ticks
        tickProvider.start()
    }

    func dispatchTick() {
        tickProvider.dispatchTick()
    }
}

// MARK: - Chain of Responsibility
extension Swashteroids {
    /// This is the player’s avatar.
    var ship: Entity? { engine.ship }

    func removeShipControlButtons() {
        creator.removeShipControlButtons()
    }

    func enableShipControlButtons() {
        creator.enableShipControlButtons()
    }

    func createShipControlButtons() {
        creator.createShipControlButtons()
    }
}
