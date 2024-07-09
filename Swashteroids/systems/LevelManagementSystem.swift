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
import Swash
import SpriteKit

class LevelManagementNode: Node {
    required init() {
        super.init()
        components = [
            GameStateComponent.name: nil_component,
        ]
    }
}

class LevelManagementSystem: ListIteratingSystem {
    private weak var engine: Engine!
    private weak var asteroidCreator: AsteroidCreatorUseCase!
    private var asteroids: NodeList!
    private var players: NodeList!
    private var minimumAsteroidDistance: CGFloat = 80
    private weak var randomness: Randomizing!
    private weak var scene: GameScene!
    private var hudTextFontSize: CGFloat = 64
    private let hudTextFontName = "Futura Condensed Medium"

    init(asteroidCreator: AsteroidCreatorUseCase, 
         scene: GameScene,
         randomness: Randomizing = Randomness.shared,
         scaleManager: ScaleManaging = ScaleManager.shared) {
        super.init(nodeClass: LevelManagementNode.self)
        self.asteroidCreator = asteroidCreator
        self.scene = scene
        self.randomness = randomness
        nodeUpdateFunction = updateNode
        hudTextFontSize *= scaleManager.SCALE_FACTOR
    }

    override func addToEngine(engine: Engine) {
        super.addToEngine(engine: engine)
        self.engine = engine
        asteroids = engine.getNodeList(nodeClassType: AsteroidCollisionNode.self)
        players = engine.getNodeList(nodeClassType: PlayerNode.self)
    }

    func updateNode(node: Node, time: TimeInterval) {
        guard let appStateComponent = node[GameStateComponent.self],
              let entity = node.entity
        else { return }
        if asteroids.empty,
           appStateComponent.numShips > 0 {
            goToNextLevel(appStateComponent: appStateComponent, entity: entity)
        }
    }

    /// Go to the next level, announce it, create asteroids
    func goToNextLevel(appStateComponent: GameStateComponent, entity: Entity) {
        guard let playerNode = players.head,
              let playerPosition = playerNode[PositionComponent.self] else { return }
        appStateComponent.level += 1
        entity.add(component: AudioComponent(name: "levelUp", fileName: .levelUpSound))
        announceLevel(appStateComponent: appStateComponent)
        createAsteroids(count: appStateComponent.level,
                        avoiding: playerPosition.point,
                        level: appStateComponent.level)
    }

    /// Create asteroids
    func createAsteroids(count: Int, avoiding positionToAvoid: CGPoint, level: Int) {
        for _ in 0..<count {
            var position: CGPoint
            repeat {
                position = randomPosition()
            } while (position.distance(from: positionToAvoid) <= minimumAsteroidDistance)
            asteroidCreator.createAsteroid(radius: LARGE_ASTEROID_RADIUS,
                                           x: position.x,
                                           y: position.y,
                                           size: .large,
                                           level: level)
        }
    }

    var size: CGSize { scene.size }

    /// Create a random position on the screen
    func randomPosition() -> CGPoint {
        let isVertical = randomness.nextBool()
        let isPositive = randomness.nextBool()
        if isVertical {
            let y = isPositive ? Double(size.height) : 0.0
            return CGPoint(x: randomness.nextDouble(from: 0.0, through: 1.0) * size.width, y: y)
        } else {
            let x = isPositive ? Double(size.width) : 0.0
            return CGPoint(x: x, y: randomness.nextDouble(from: 0.0, through: 1.0) * size.height)
        }
    }

    /// Announce the level
    func announceLevel(appStateComponent: GameStateComponent) {
        let levelText = SKLabelNode(text: "Level \(appStateComponent.level)")
        configureLevelText(levelText)
        scene.addChild(levelText)
        animateLevelText(levelText)
    }

    // MARK: - HUD Helpers
    /// Configure the level text
    func configureLevelText(_ levelText: SKLabelNode) {
        levelText.horizontalAlignmentMode = .center
        levelText.fontName = hudTextFontName
        levelText.fontColor = .hudText
        levelText.fontSize = hudTextFontSize
        levelText.position = CGPoint(x: size.width / 2, y: size.height / 2 * 1.2)
        levelText.zPosition = .top
    }

    /// Animate the level text
    func animateLevelText(_ levelText: SKLabelNode) {
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
