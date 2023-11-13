import Foundation
import Swash


final class WaitForStartSystem: System {
    private var keyPoll: KeyPoll
    private var engine: Engine?
    private var creator: EntityCreator?
    private var gameNodes: NodeList?
    private var waitNodes: NodeList?
    private var asteroids: NodeList?

    init(_ creator: EntityCreator, keyPoll: KeyPoll) {
        self.creator = creator
        self.keyPoll = keyPoll
    }

    public override func addToEngine(engine: Engine) {
        self.engine = engine
        waitNodes = engine.getNodeList(nodeClassType: WaitForStartNode.self)
        gameNodes = engine.getNodeList(nodeClassType: GameNode.self)
        asteroids = engine.getNodeList(nodeClassType: AsteroidCollisionNode.self)
    }

    public override func update(time: TimeInterval) {
        guard let waitNode = waitNodes?.head,
              let gameNode = gameNodes?.head,
              let gameStateComponent = gameNode[GameStateComponent.self]
        else { return }
        if keyPoll.tapped {
            // Clear any existing asteroids
            var asteroid = asteroids?.head
            while asteroid != nil {
                creator?.destroyEntity(asteroid!.entity!)
                asteroid = asteroid?.next
            }
            // Start state
            gameStateComponent.resetBoard()
            keyPoll.tapped = false
            engine?.removeEntity(entity: waitNode.entity!)
        }
    }

    public override func removeFromEngine(engine: Engine) {
        gameNodes = nil
        waitNodes = nil
    }
}
