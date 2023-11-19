//
// Created by John Nyquist on 12/13/22.
//

import Swash
import SpriteKit

struct GameConfig {
	var width: Double
	var height: Double
}

public class Asteroids {
	var config: GameConfig!
	var engine: Engine!
	var tickProvider: FrameTickProvider!
	private var container: SKScene
	private var creator: EntityCreator!

	public init(container: SKScene, width: Double, height: Double) {
		self.container = container
		prepare(width: width, height: height)
	}

	private func prepare(width: Double, height: Double) {
		engine = Engine()
		creator = EntityCreator(engine: engine)
		config = GameConfig(width: 1024, height: 768)
		engine
			.addSystem(system: AnimationSystem(), priority: SystemPriorities.animate.rawValue)
			.addSystem(system: AudioSystem(scene: container), priority: SystemPriorities.render.rawValue)
			.addSystem(system: BulletAgeSystem(creator: creator), priority: SystemPriorities.update.rawValue)
			.addSystem(system: CollisionSystem(creator), priority: SystemPriorities.resolveCollisions.rawValue)
			.addSystem(system: DeathThroesSystem(creator: creator), priority: SystemPriorities.update.rawValue)
			.addSystem(system: FiringControlsSystem(creator: creator), priority: SystemPriorities.update.rawValue)
			.addSystem(system: GameManagerSystem(creator: creator, config: config, scene: container as? GameScene), priority: SystemPriorities.preUpdate.rawValue)
			.addSystem(system: HudSystem(), priority: SystemPriorities.animate.rawValue)
			.addSystem(system: HyperSpaceSystem(config: config, scene: container), priority: SystemPriorities.update.rawValue)
			.addSystem(system: MotionControlsSystem(), priority: SystemPriorities.update.rawValue)
			.addSystem(system: MovementSystem(config: config), priority: SystemPriorities.move.rawValue)
			.addSystem(system: RenderSystem(container: container), priority: SystemPriorities.render.rawValue)
			.addSystem(system: ShipEngineSystem(), priority: SystemPriorities.update.rawValue)
			.addSystem(system: WaitForStartSystem(creator), priority: SystemPriorities.preUpdate.rawValue)
		creator.createWaitForClick()
		creator.createHud()
		creator.createButtons()
	}

	func start() {
		tickProvider = FrameTickProvider()
		tickProvider.add(Listener(engine.update)) // Then engine listens for ticks
		tickProvider.start()
	}
}
