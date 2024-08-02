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
Determines if a ship needs to be made.
 */
final class ShipCreationSystem: System {
    private let shipClearanceRadius: CGFloat = 50
    private let shipPositionRatio: CGFloat = 0.5
    private var gameSize: CGSize
    private weak var aliens: NodeList!
    private weak var appStates: NodeList!
    private weak var asteroids: NodeList!
    private weak var playerCreator: PlayerCreatorUseCase!
    private weak var players: NodeList!
    private weak var randomness: Randomizing!
    private weak var torpedoes: NodeList!

    init(playerCreator: PlayerCreatorUseCase,
         gameSize: CGSize,
         randomness: Randomizing = Randomness.shared) {
        self.playerCreator = playerCreator
        self.gameSize = gameSize
        self.randomness = randomness
    }

    // MARK: - System Overrides
    override func addToEngine(engine: Engine) {
        appStates = engine.getNodeList(nodeClassType: SwashteroidsStateNode.self)
        players = engine.getNodeList(nodeClassType: PlayerNode.self)
        asteroids = engine.getNodeList(nodeClassType: AsteroidCollisionNode.self)
        torpedoes = engine.getNodeList(nodeClassType: TorpedoCollisionNode.self)
        aliens = engine.getNodeList(nodeClassType: AlienCollisionNode.self)
    }

    override func removeFromEngine(engine: Engine) {
        appStates = nil
        players = nil
        asteroids = nil
        torpedoes = nil
        aliens = nil
    }

    override func update(time: TimeInterval) {
        guard let currentStateNode = appStates.head as? SwashteroidsStateNode,
              let appStateComponent = currentStateNode[GameStateComponent.self],
              appStateComponent.gameScreen == .playing
        else { return }
        checkForShips(appStateComponent: appStateComponent)
    }

    // MARK: - Game Logic
    /// If there are no ships and is playing, handle it. 
    /// If there are no asteroids, no torpedoes and there is a ship then you finished the level, go to the next.
    func checkForShips(appStateComponent: GameStateComponent) {
        // No ships in the NodeList, but we're still playing.
        if players.empty {
            // If we have any ships left, make another and some power-ups
            if appStateComponent.numShips > 0 {
                let newSpaceshipPosition = CGPoint(x: gameSize.width * shipPositionRatio,
                                                   y: gameSize.height * shipPositionRatio)
                if isClearToAddSpaceship(at: newSpaceshipPosition) {
                    playerCreator.createPlayer(appStateComponent)
                }
            }
        }
    }

    /// Detects if there is an asteroid too close to the new spaceship position
    func isClearToAddSpaceship(at position: CGPoint) -> Bool {
        guard aliens.head == nil else { return false }
        var currentAsteroidNode = asteroids.head
        while let asteroid = currentAsteroidNode {
            if let positionComponent = asteroid[PositionComponent.self],
               let collisionComponent = asteroid[CollidableComponent.self] {
                if positionComponent.point.distance(from: position) <= collisionComponent.radius + shipClearanceRadius {
                    return false
                }
            }
            currentAsteroidNode = asteroid.next
        }
        return true
    }
}

