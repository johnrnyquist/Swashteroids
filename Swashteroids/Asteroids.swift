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
	private var container: SKScene
	private var creator: EntityCreator!
	private var engine: Engine!
	var tickProvider: FrameTickProvider!
	var keyPoll: KeyPoll!

	public init(container: SKScene, width: Double, height: Double, keyPoll: KeyPoll) {
		self.container = container
		self.keyPoll = keyPoll //HACK
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
			.addSystem(system: FiringControlsSystem(keyPoll: keyPoll, creator: creator), priority: SystemPriorities.update.rawValue)
			.addSystem(system: GameManagerSystem(creator: creator, config: config, scene: container as? GameScene), priority: SystemPriorities.preUpdate.rawValue)
			.addSystem(system: HudSystem(), priority: SystemPriorities.animate.rawValue)
			.addSystem(system: HyperSpaceSystem(config: config, scene: container), priority: SystemPriorities.update.rawValue)
			.addSystem(system: MotionControlsSystem(keyPoll: keyPoll), priority: SystemPriorities.update.rawValue)
			.addSystem(system: MovementSystem(config: config), priority: SystemPriorities.move.rawValue)
			.addSystem(system: RenderSystem(container: container), priority: SystemPriorities.render.rawValue)
			.addSystem(system: ShipEngineSystem(), priority: SystemPriorities.update.rawValue)
			.addSystem(system: WaitForStartSystem(creator, keyPoll: keyPoll), priority: SystemPriorities.preUpdate.rawValue)
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
