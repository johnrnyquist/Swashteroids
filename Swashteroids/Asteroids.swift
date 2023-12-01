//
// Created by John Nyquist on 12/13/22.
//

import Swash
import SpriteKit


final public class Asteroids {
     var engine: Engine
    private var tickProvider: FrameTickProvider
    private var scene: SKScene
      var creator: EntityCreator!
    
	var input: InputComponent
    var ship: Entity? { engine.ship }
	var wait: Entity? { engine.wait }
	var gameOver: Entity? { engine.gameOver }

	public init(scene: SKScene) {
        self.scene = scene
		input = InputComponent()
        engine = Engine()
		creator = EntityCreator(engine: engine, input: input, scene: scene, size: scene.size)
        tickProvider = FrameTickProvider()

        engine
                .addSystem(system: AnimationSystem(), priority: SystemPriorities.animate.rawValue)
                .addSystem(system: AudioSystem(scene: scene), priority: SystemPriorities.render.rawValue)
                .addSystem(system: BulletAgeSystem(creator: creator), priority: SystemPriorities.update.rawValue)
                .addSystem(system: CollisionSystem(creator), priority: SystemPriorities.resolveCollisions.rawValue)
                .addSystem(system: DeathThroesSystem(creator: creator), priority: SystemPriorities.update.rawValue)
                .addSystem(system: FiringControlsSystem(creator: creator), priority: SystemPriorities.update.rawValue)
				.addSystem(system: GameManagerSystem(creator: creator, size: scene.size, scene: scene),
                           priority: SystemPriorities.preUpdate.rawValue)
                .addSystem(system: HudSystem(), priority: SystemPriorities.animate.rawValue)
                .addSystem(system: HyperSpaceSystem(scene: scene),
                           priority: SystemPriorities.update.rawValue)
                .addSystem(system: MotionControlsSystem(), priority: SystemPriorities.update.rawValue)
                .addSystem(system: MovementSystem(size: scene.size), priority: SystemPriorities.move.rawValue)
                .addSystem(system: RenderSystem(container: scene), priority: SystemPriorities.render.rawValue)
                .addSystem(system: ShipEngineSystem(), priority: SystemPriorities.update.rawValue)
				.addSystem(system: WaitForStartSystem(creator, scene: scene), priority: SystemPriorities.preUpdate.rawValue)
				.addSystem(system: GameOverSystem(creator), priority: SystemPriorities.preUpdate.rawValue)

		creator.createWaitForTap(gameState: GameStateComponent())
    }


    func start() {
        tickProvider.add(Listener(engine.update)) // Then engine listens for ticks
        tickProvider.start()
    }

    func dispatchTick() {
        tickProvider.dispatchTick()
    }
}

