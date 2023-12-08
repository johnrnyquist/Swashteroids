import Foundation
import Swash


final class GameOverSystem: System {
	private weak var engine: Engine?
	private weak var creator: Creator?
	private weak var gameOverNodes: NodeList?
	private weak var gameNodes: NodeList?
	private weak var asteroids: NodeList?

	init(_ creator: Creator) {
		self.creator = creator
	}

	override public func addToEngine(engine: Engine) {
		self.engine = engine
		gameOverNodes = engine.getNodeList(nodeClassType: GameOverNode.self)
		gameNodes = engine.getNodeList(nodeClassType: AppStateNode.self)
		asteroids = engine.getNodeList(nodeClassType: AsteroidCollisionNode.self)
	}

	override public func update(time: TimeInterval) {
		guard let gameOverNode = gameOverNodes?.head,
			  let input = gameOverNode[InputComponent.self],
			  let gameNode = gameNodes?.head,
			  let appStateComponent = gameNode[AppStateComponent.self]
		else { return }
		if input.tapped {
			// Clear any existing asteroids
			var asteroid = asteroids?.head
			while asteroid != nil {
				creator?.destroyEntity(asteroid!.entity!)
				asteroid = asteroid?.next
			}
			input.tapped = false
			if let engine {
				engine.removeEntity(entity: gameOverNode.entity!)
				engine.removeEntity(entity: engine.getEntity(named: .hud)!)
				if let gun = engine.getEntity(named: .plasmaTorpedoesPowerUp) {
					engine.removeEntity(entity: gun)
				}
			}
			appStateComponent.playing = false
			//TODO: Transition to START
		}
	}

	override public func removeFromEngine(engine: Engine) {
		self.engine = nil
		creator = nil
		gameOverNodes = nil
		asteroids = nil
	}
}
