import Foundation
import Swash


/// Detects if there are no ships, if game is playing, if there are no asteroids, no bullets.
/// Determines when to go to next level.
/// Creates the level.
/// Determines if a ship needs to be made.
final class GameManagerSystem: System {
    private var size: CGSize
    private weak var creator: EntityCreator!
    private weak var asteroids: NodeList!
    private weak var bullets: NodeList!
    private weak var gameNodes: NodeList!
    private weak var ships: NodeList!

	
    init(creator: EntityCreator, size: CGSize) {
        self.creator = creator
        self.size = size
    }

    public override func addToEngine(engine: Engine) {
        gameNodes = engine.getNodeList(nodeClassType: GameStateNode.self)
        ships = engine.getNodeList(nodeClassType: ShipNode.self)
        asteroids = engine.getNodeList(nodeClassType: AsteroidCollisionNode.self)
        bullets = engine.getNodeList(nodeClassType: BulletCollisionNode.self)
    }

    public override func update(time: TimeInterval) {
        guard let gameNode = gameNodes.head,
              let gameStateComponent = gameNode[GameStateComponent.self] else {
            return
        }
        if ships.empty, gameStateComponent.playing {
            if gameStateComponent.ships > 0 {
                let newSpaceshipPosition = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
                var clearToAddSpaceship = true
                var asteroid = asteroids.head
                while asteroid != nil {
                    guard let positionComponent = asteroid?[PositionComponent.self],
                          let collisionComponent = asteroid?[CollisionComponent.self]
                    else { continue }
                    if positionComponent.position.distance(p: newSpaceshipPosition) <= collisionComponent.radius + 50 {
                        clearToAddSpaceship = false
                        break
                    }
                    asteroid = asteroid?.next
                }
                if clearToAddSpaceship {
					creator.createShip()
                    creator.createGunSupplier()
                }
            } else if gameStateComponent.playing {
                gameStateComponent.playing = false
                creator.createGameOver()
            }
        }
        if asteroids.empty, bullets.empty, !ships.empty {
            // next level
            guard
                let shipNode = ships.head,
                let spaceShipPosition = shipNode[PositionComponent.self] 
            else { return }
            gameStateComponent.level += 1
            let asteroidCount = 0 + gameStateComponent.level
            for _ in 0..<asteroidCount {
                // check not on top of ship
                var position: CGPoint
                repeat {
                    // Randomly decide if the asteroid will be created along the vertical or horizontal bounds
                    let isVertical = Bool.random()
                    // Randomly decide if the asteroid will be created along the positive or negative bound
                    let isPositive = Bool.random()
                    if isVertical {
                        // If isVertical is true, create the asteroid along the top or bottom bound
                        let y = isPositive ? Double(size.height) : 0.0
                        position = CGPoint(x: Double.random(in: 0.0...1.0) * size.width, y: y)
                    } else {
                        // If isVertical is false, create the asteroid along the left or right bound
                        let x = isPositive ? Double(size.width) : 0.0
                        position = CGPoint(x: x, y: Double.random(in: 0.0...1.0) * size.height)
                    }
                    // Repeat until the asteroid is not on top of the ship
                } while (position.distance(p: spaceShipPosition.position) <= 80)
                // Create the asteroid at the calculated position
                creator.createAsteroid(radius: LARGE_ASTEROID_RADIUS, x: position.x, y: position.y)
            }
        }
    }

    public override func removeFromEngine(engine: Engine) {
		creator = nil
        gameNodes = nil
        ships = nil
        asteroids = nil
        bullets = nil
    }
}


