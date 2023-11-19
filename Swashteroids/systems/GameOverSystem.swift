import Foundation
import Swash


final class GameOverSystem: System {
	private weak var engine: Engine?
	private weak var creator: EntityCreator?
	private weak var gameOverNodes: NodeList?
	private weak var asteroids: NodeList?

	init(_ creator: EntityCreator) {
		self.creator = creator
	}

	public override func addToEngine(engine: Engine) {
		self.engine = engine
		gameOverNodes = engine.getNodeList(nodeClassType: GameOverNode.self)
		asteroids = engine.getNodeList(nodeClassType: AsteroidCollisionNode.self)
	}

	public override func update(time: TimeInterval) {
		guard let gameOverNode = gameOverNodes?.head,
			  let input = gameOverNode[InputComponent.self]
		else { return }
		if input.tapped {
			// Clear any existing asteroids
			var asteroid = asteroids?.head
			while asteroid != nil {
				creator?.destroyEntity(asteroid!.entity!)
				asteroid = asteroid?.next
			}
			input.tapped = false
			engine?.removeEntity(entity: gameOverNode.entity!)
			creator?.createWaitForTap()
		}
	}

	public override func removeFromEngine(engine: Engine) {
		self.engine = nil
		creator = nil
		gameOverNodes = nil
		asteroids = nil
	}
}
