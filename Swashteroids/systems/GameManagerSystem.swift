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
Has too many responsibilities.
 */
final class GameManagerSystem: System {
    private var size: CGSize
    private weak var scene: SKScene!
    private weak var creator: (PowerUpCreator & ShipCreator & AsteroidCreator & TorpedoCreator)!
    private weak var asteroids: NodeList!
    private weak var torpedoes: NodeList!
    private weak var appStates: NodeList!
    private weak var ships: NodeList!
    private let spaceshipPositionRatio: CGFloat = 0.5
    private let levelUpSound = "braam-6150.wav"
    private let minimumLevel = 1
    private let hudTextFontName = "Futura Condensed Medium"
    private var hudTextFontSize: CGFloat = 64
    private var spaceshipClearanceRadius: CGFloat = 50
    private var minimumAsteroidDistance: CGFloat = 80

    init(creator: PowerUpCreator & ShipCreator & AsteroidCreator & TorpedoCreator, 
         size: CGSize, scene: SKScene, 
         scaleManager: ScaleManaging = ScaleManager.shared) {
        self.creator = creator
        self.size = size
        self.scene = scene
        spaceshipClearanceRadius *= scaleManager.SCALE_FACTOR
        minimumAsteroidDistance *= scaleManager.SCALE_FACTOR
        hudTextFontSize *= scaleManager.SCALE_FACTOR
    }

    // MARK: - System Overrides
    override func addToEngine(engine: Engine) {
        appStates = engine.getNodeList(nodeClassType: AppStateNode.self)
        ships = engine.getNodeList(nodeClassType: ShipNode.self)
        asteroids = engine.getNodeList(nodeClassType: AsteroidCollisionNode.self)
        torpedoes = engine.getNodeList(nodeClassType: PlasmaTorpedoCollisionNode.self)
    }

    override func update(time: TimeInterval) {
        guard let currentStateNode = appStates.head,
              let appStateComponent = currentStateNode[AppStateComponent.self] else { return }
        handleGameState(appStateComponent: appStateComponent, currentStateNode: currentStateNode)
    }

    override func removeFromEngine(engine: Engine) {
        creator = nil
        appStates = nil
        ships = nil
        asteroids = nil
        torpedoes = nil
    }

    // MARK: - Game Logic
    private func handleGameState(appStateComponent: AppStateComponent, currentStateNode: Node) {
        // No ships in the NodeList, but we're still playing.
        if ships.empty,
           appStateComponent.appState == .playing {
            handlePlayingState(appStateComponent: appStateComponent, currentStateNode: currentStateNode)
        }
        // No asteroids or torpedoes but we have a ship, so start a new level.
        if asteroids.empty,
           torpedoes.empty,
           !ships.empty {
            goToNextLevel(appStateComponent: appStateComponent, currentStateNode: currentStateNode)
        }
    }

    private func handlePlayingState(appStateComponent: AppStateComponent, currentStateNode: Node) {
        // If we have any ships left, make another and some power-ups
        if appStateComponent.numShips > 0 {
            let newSpaceshipPosition = CGPoint(x: size.width * spaceshipPositionRatio,
                                               y: size.height * spaceshipPositionRatio)
            if isClearToAddSpaceship(at: newSpaceshipPosition) {
                creator.createShip(appStateComponent)
                let level = max(appStateComponent.level, minimumLevel)
                createPowerUps(level: level)
            }
        } else { // GAME OVER!
            currentStateNode.entity?.add(component: TransitionAppStateComponent(to: .gameOver, from: .playing))
        }
    }

    private func goToNextLevel(appStateComponent: AppStateComponent, currentStateNode: Node) {
        guard let shipNode = ships.head,
              let spaceShipPosition = shipNode[PositionComponent.self] else { return }
        appStateComponent.level += 1
        currentStateNode.entity?.add(component: AudioComponent(fileNamed: levelUpSound, actionKey: "levelUp"))
        announceLevel(appStateComponent: appStateComponent)
        createAsteroids(count: appStateComponent.level, avoiding: spaceShipPosition.position, level: appStateComponent.level)
    }

    private func isClearToAddSpaceship(at position: CGPoint) -> Bool {
        var asteroid = asteroids.head
        while let currentAsteroid = asteroid {
            guard let positionComponent = currentAsteroid[PositionComponent.self],
                  let collisionComponent = currentAsteroid[CollisionComponent.self] else {
                asteroid = currentAsteroid.next
                continue
            }
            if positionComponent.position.distance(from: position) <= collisionComponent.radius + spaceshipClearanceRadius {
                return false
            }
            asteroid = currentAsteroid.next
        }
        return true
    }

    private func createPowerUps(level: Int) {
        creator.createPlasmaTorpedoesPowerUp(level: level)
        creator.createHyperspacePowerUp(level: level)
    }

    private func createAsteroids(count: Int, avoiding positionToAvoid: CGPoint, level: Int) {
        for _ in 0..<count {
            var position: CGPoint
            repeat {
                position = randomPosition()
            } while (position.distance(from: positionToAvoid) <= minimumAsteroidDistance)
            creator.createAsteroid(radius: LARGE_ASTEROID_RADIUS, x: position.x, y: position.y, level: level)
        }
    }

    private func randomPosition() -> CGPoint {
        let isVertical = Bool.random()
        let isPositive = Bool.random()
        if isVertical {
            let y = isPositive ? Double(size.height) : 0.0
            return CGPoint(x: Double.random(in: 0.0...1.0) * size.width, y: y)
        } else {
            let x = isPositive ? Double(size.width) : 0.0
            return CGPoint(x: x, y: Double.random(in: 0.0...1.0) * size.height)
        }
    }

    private func announceLevel(appStateComponent: AppStateComponent) {
        let levelText = SKLabelNode(text: "Level \(appStateComponent.level)")
        configureLevelText(levelText)
        scene.addChild(levelText)
        animateLevelText(levelText)
    }

    // MARK: - HUD Helpers
    private func configureLevelText(_ levelText: SKLabelNode) {
        levelText.horizontalAlignmentMode = .center
        levelText.fontName = hudTextFontName
        levelText.fontColor = .hudText
        levelText.fontSize = hudTextFontSize
        levelText.position = CGPoint(x: size.width / 2, y: size.height / 2 * 1.2)
        levelText.zPosition = Layer.top.rawValue
    }

    private func animateLevelText(_ levelText: SKLabelNode) {
        let zoomInAction = SKAction.scale(to: 2.0, duration: 0.5)
        zoomInAction.timingMode = .easeIn
        let waitAction = SKAction.wait(forDuration: 1.0)
        let fade = SKAction.fadeOut(withDuration: 0.25)
        let sequence = SKAction.sequence([zoomInAction, waitAction, fade])
        levelText.run(sequence) {
            levelText.removeFromParent()
        }
    }
}
