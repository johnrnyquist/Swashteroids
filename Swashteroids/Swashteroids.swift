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

final class Swashteroids {
    var ship: Entity? { engine.ship }
    var creator: Creator
    private var scene: GameScene
    private var engine: Engine
    private var tickProvider: FrameTickProvider

    init(scene: GameScene, inputComponent: InputComponent) {
        self.scene = scene
        engine = Engine()
        let appStateComponent = AppStateComponent()
        let appStateEntity = Entity(name: .appState)
                .add(component: appStateComponent)
                .add(component: TransitionAppStateComponent(to: .initialize))
        try? engine.addEntity(entity: appStateEntity)
        creator = Creator(engine: engine, appStateEntity: appStateEntity, inputComponent: inputComponent, scene: scene, size: scene.size)
        tickProvider = FrameTickProvider()
        let inputEntity = Entity(name: .inputEntity)
                .add(component: inputComponent)
        try? engine.addEntity(entity: inputEntity)
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
                .addSystem(system: BulletAgeSystem(creator: creator), priority: .update)
                .addSystem(system: DeathThroesSystem(creator: creator), priority: .update)
                .addSystem(system: FiringSystem(creator: creator), priority: .update)
                .addSystem(system: HyperSpaceSystem(scene: scene), priority: .update)
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