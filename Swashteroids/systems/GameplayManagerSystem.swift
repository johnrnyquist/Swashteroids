//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import Foundation
import SpriteKit
import Swash

/**
Detects if there are no ships, if game is playing, if there are no asteroids, no torpedoes.
Determines when to go to next level.
Creates the level.
Determines if a ship needs to be made.
 */
//TODO: Has too many responsibilities, needs to be reconsidered.
class GameplayManagerSystem: System {
    private let minimumLevel = 1
    private let spaceshipPositionRatio: CGFloat = 0.5
    private var spaceshipClearanceRadius: CGFloat = 50
    private weak var alienCreator: AlienCreatorUseCase!
    private weak var appStates: NodeList!
    private weak var asteroidCreator: AsteroidCreatorUseCase!
    private weak var randomness: Randomizing!
    private weak var scene: GameScene!
    private weak var shipCreator: ShipCreatorUseCase!
    private weak var ships: NodeList!
    private weak var torpedoes: NodeList!
    weak var aliens: NodeList!
    weak var asteroids: NodeList!

    init(asteroidCreator: AsteroidCreatorUseCase,
         alienCreator: AlienCreatorUseCase,
         shipCreator: ShipCreatorUseCase,
         scene: GameScene,
         randomness: Randomizing = Randomness.shared) {
        self.asteroidCreator = asteroidCreator
        self.alienCreator = alienCreator
        self.shipCreator = shipCreator
        self.scene = scene
        self.randomness = randomness
    }

    // MARK: - System Overrides
    override func addToEngine(engine: Engine) {
        appStates = engine.getNodeList(nodeClassType: SwashteroidsStateNode.self)
        ships = engine.getNodeList(nodeClassType: ShipNode.self)
        asteroids = engine.getNodeList(nodeClassType: AsteroidCollisionNode.self)
        torpedoes = engine.getNodeList(nodeClassType: TorpedoCollisionNode.self)
        aliens = engine.getNodeList(nodeClassType: AlienCollisionNode.self)
    }

    override func removeFromEngine(engine: Engine) {
        appStates = nil
        ships = nil
        asteroids = nil
        torpedoes = nil
        aliens = nil
    }

    override func update(time: TimeInterval) {
        guard let currentStateNode = appStates.head as? SwashteroidsStateNode,
              let entity = currentStateNode.entity,
              let appStateComponent = currentStateNode[GameStateComponent.self],
              appStateComponent.gameState == .playing
        else { return }
        handleGameState(appStateComponent: appStateComponent, entity: entity, time: time)
    }

    // MARK: - Game Logic
    /// If there are no ships and is playing, handle it. 
    /// If there are no asteroids, no torpedoes and there is a ship then you finished the level, go to the next.
    func handleGameState(appStateComponent: GameStateComponent, entity: Entity, time: TimeInterval) {
        // No ships in the NodeList, but we're still playing.
        if ships.empty {
            continueOrEnd(appStateComponent: appStateComponent, entity: entity)
        }
    }

    /// If we have ships, make one. Otherwise, go to game over state.
    func continueOrEnd(appStateComponent: GameStateComponent, entity: Entity) {
        // If we have any ships left, make another and some power-ups
        if appStateComponent.numShips > 0 {
            let newSpaceshipPosition = CGPoint(x: scene.size.width * spaceshipPositionRatio,
                                               y: scene.size.height * spaceshipPositionRatio)
            if isClearToAddSpaceship(at: newSpaceshipPosition) {
                shipCreator.createShip(appStateComponent)
            }
        } else { // GAME OVER!
            entity.add(component: TransitionAppStateComponent(from: .playing, to: .gameOver))
        }
    }

    /// Detects if there is an asteroid too close to the new spaceship position
    func isClearToAddSpaceship(at position: CGPoint) -> Bool {
        guard aliens.head == nil else { return false }
        var currentAsteroidNode = asteroids.head
        while let asteroid = currentAsteroidNode {
            if let positionComponent = asteroid[PositionComponent.self],
               let collisionComponent = asteroid[CollidableComponent.self] {
                if positionComponent.position.distance(from: position) <= collisionComponent.radius + spaceshipClearanceRadius {
                    return false
                }
            }
            currentAsteroidNode = asteroid.next
        }
        return true
    }
}

