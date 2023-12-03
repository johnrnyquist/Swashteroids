import Foundation
import Swash
import SpriteKit

final class WaitForStartSystem: System {
    private weak var engine: Engine?
    private weak var creator: EntityCreator?
    private weak var gameNodes: NodeList?
    private weak var waitNodes: NodeList?
    private weak var asteroids: NodeList?
	private weak var scene: SKScene!

	init(_ creator: EntityCreator, scene: SKScene) {
        self.creator = creator
		self.scene = scene
    }

    override public func addToEngine(engine: Engine) {
        self.engine = engine
        waitNodes = engine.getNodeList(nodeClassType: WaitForStartNode.self)
        gameNodes = engine.getNodeList(nodeClassType: GameStateNode.self)
        asteroids = engine.getNodeList(nodeClassType: AsteroidCollisionNode.self)
    }

    override public func update(time: TimeInterval) {
        guard let waitNode = waitNodes?.head,
			  let waitView = waitNode[DisplayComponent.self]?.displayObject as? WaitForStartView,
              let input = waitNode[InputComponent.self],
              let gameNode = gameNodes?.head,
              let gameStateComponent = gameNode[GameStateComponent.self]
        else { return }

        if input.tapped {
            input.tapped = false
            if input.noButtonsIsDown == false && input.buttonsIsDown == false {
                return
            }
            if input.noButtonsIsDown {
                if waitView.quadrants.alpha == 0 {
                    waitView.showQuadrants()
                    return
                } else {
                    waitView.hideQuadrants()
					creator?.createShowHideButtons("hide")
                }
            } else if input.buttonsIsDown {
                if waitView.buttonsInfo.alpha == 0 {
                    waitView.showButtonsInfo()
                    return
                } else {
                    waitView.hideButtonsInfo()
					creator?.createShowHideButtons("show")
                }
            }
            // Start state
            gameStateComponent.resetBoard()
            gameStateComponent.playing = true
            engine?.removeEntity(entity: waitNode.entity!)
            creator?.createHud(gameState: gameStateComponent)
        }
    }

    override public func removeFromEngine(engine: Engine) {
        self.engine = nil
        creator = nil
        gameNodes = nil
        waitNodes = nil
        asteroids = nil
    }
}
