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

/// Detects if there are no ships, if game is playing, if there are no asteroids, no bullets.
/// Determines when to go to next level.
/// Creates the level.
/// Determines if a ship needs to be made.
final class GameManagerSystem: System {
    private var size: CGSize
    private weak var creator: Creator!
    private weak var asteroids: NodeList!
    private weak var bullets: NodeList!
    private weak var appStates: NodeList!
    private weak var ships: NodeList!
    private weak var scene: SKScene!

    init(creator: Creator, size: CGSize, scene: SKScene) {
        self.creator = creator
        self.size = size
        self.scene = scene
    }

    override public func addToEngine(engine: Engine) {
        appStates = engine.getNodeList(nodeClassType: AppStateNode.self)
        ships = engine.getNodeList(nodeClassType: ShipNode.self)
        asteroids = engine.getNodeList(nodeClassType: AsteroidCollisionNode.self)
        bullets = engine.getNodeList(nodeClassType: PlasmaTorpedoCollisionNode.self)
    }

    override public func update(time: TimeInterval) {
        guard let appStateNode = appStates.head,
              let appStateComponent = appStateNode[AppStateComponent.self] else {
            return
        }
        if ships.empty,
           appStateComponent.playing {
            if appStateComponent.ships > 0 {
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
                    creator.createShip(appStateComponent.shipControlsState)
                    creator.createPlasmaTorpedoesPowerUp(level: appStateComponent.level == 0 ? 1 : appStateComponent.level)
                }
            } else if appStateComponent.playing {
                appStateComponent.playing = false
                creator.removeShipControlButtons()
                creator.removeToggleButton()
                creator.setUpGameOver()
            }
        }
        if asteroids.empty,
           bullets.empty,
           !ships.empty {
            // next level
            guard
                let shipNode = ships.head,
                let spaceShipPosition = shipNode[PositionComponent.self]
            else { return }
            appStateComponent.level += 1
            //TODO: This level text and animation should be elsewhere.
            announceLevel(appStateComponent: appStateComponent)
            //
            let asteroidCount = 0 + appStateComponent.level
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

    private func announceLevel(appStateComponent: AppStateComponent) {
        scene.run(SKAction.playSoundFileNamed("braam-6150.wav", waitForCompletion: false))
        let levelText = SKLabelNode(text: "Level \(appStateComponent.level)")
        scene.addChild(levelText)
        levelText.horizontalAlignmentMode = .center
        levelText.fontName = "Futura Condensed Medium"
        levelText.fontColor = .hudText
        levelText.fontSize = 64
        levelText.position = CGPoint(x: size.width / 2, y: size.height / 2 * 1.2)
        let zoomInAction = SKAction.scale(to: 2.0, duration: 0.5)
        zoomInAction.timingMode = .easeIn
        let waitAction = SKAction.wait(forDuration: 1.0)
        let fade = SKAction.fadeOut(withDuration: 0.25)
        let sequence = SKAction.sequence([zoomInAction, waitAction, fade])
        levelText.run(sequence) {
            levelText.removeFromParent()
        }
    }

    override public func removeFromEngine(engine: Engine) {
        creator = nil
        appStates = nil
        ships = nil
        asteroids = nil
        bullets = nil
    }
}