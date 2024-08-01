//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import Swash
import Foundation.NSDate
import SpriteKit

enum TutorialStep: CaseIterable {
    case thisIsYourShip
    case thrusting
    case turning
    case flipping
    case hud
    case powerups
    case tryFiring
    case tryHyperspace
    case asteroid
    case treasure
    case complete
    case none
}

enum TutorialCompletion {
    case notStarted
    case inProgress
    case completed
}

class TutorialTransition: TutorialUseCase {
    private let engine: Engine

    init(engine: Engine) {
        self.engine = engine
    }

    func fromTutorialScreen() {
    }

    func toTutorialScreen() {
        let tutorial = Entity(named: "Tutorial")
                .add(component: TutorialComponent(tutorialState: .thisIsYourShip))
        engine.add(entity: tutorial)
    }
}

class TutorialComponent: Component {
    var state: TutorialStep
    var completionStatus: [TutorialStep: TutorialCompletion]

    init(tutorialState: TutorialStep) {
        self.state = tutorialState
        self.completionStatus = Dictionary(uniqueKeysWithValues: TutorialStep.allCases.map { ($0, .notStarted) })
    }
}

class TutorialNode: Node {
    required init() {
        super.init()
        components = [
            TutorialComponent.name: nil,
        ]
    }
}

class TutorialSystem: ListIteratingSystem {
    let gameSize: CGSize
    var tutorialText: Entity!
    weak var engine: Engine!
    weak var playerCreator: PlayerCreatorUseCase?
    weak var shipButtonControlsCreator: ShipButtonCreatorUseCase?
    weak var systemsManager: SystemsManager?
    weak var asteroidCreator: AsteroidCreatorUseCase?
    weak var treasureCreator: TreasureCreatorUseCase?
    private var message: MessageHandler?

    init(systemsManager: SystemsManager,
         gameSize: CGSize,
         playerCreator: PlayerCreatorUseCase,
         shipButtonControlsCreator: ShipButtonCreatorUseCase,
         asteroidCreator: AsteroidCreatorUseCase,
         treasureCreator: TreasureCreatorUseCase
    ) {
        self.systemsManager = systemsManager
        self.gameSize = gameSize
        self.playerCreator = playerCreator
        self.shipButtonControlsCreator = shipButtonControlsCreator
        self.asteroidCreator = asteroidCreator
        self.treasureCreator = treasureCreator
        super.init(nodeClass: TutorialNode.self)
        nodeUpdateFunction = updateNode
    }

    override func addToEngine(engine: Engine) {
        super.addToEngine(engine: engine)
        self.engine = engine
        if tutorialText == nil {
            let skNode = SKNode()
            skNode.alpha = 1.0
            tutorialText = Entity(named: .tutorialText)
                    .add(component: DisplayComponent(sknode: skNode))
            engine.add(entity: tutorialText)
        }
        message = MessageHandler(gameSize: gameSize, tutorialText: tutorialText)
    }

    private func format(string: String) -> NSAttributedString {
        let attributed = NSMutableAttributedString(string: string)
        let range = NSRange(location: 0, length: attributed.length)
        let font = UIFont(name: "Futura Condensed Medium", size: 24.0)!
        let color = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        attributed.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
        attributed.addAttribute(NSAttributedString.Key.font, value: font, range: range)
        attributed.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        return NSAttributedString(attributedString: attributed)
    }

    private func updateNode(node: Node, time: TimeInterval) {
        guard let tutorialComponent = node[TutorialComponent.self] else { return }
        if engine.findEntity(named: .tutorialText) == nil {
            let skNode = SKNode()
            skNode.alpha = 1.0
            tutorialText = Entity(named: .tutorialText)
                    .add(component: DisplayComponent(sknode: skNode))
            engine.add(entity: tutorialText)
        }
        switch tutorialComponent.state {
            case .thisIsYourShip:
                if tutorialComponent.completionStatus[.thisIsYourShip] == .notStarted {
                    tutorialComponent.completionStatus[.thisIsYourShip] = .completed
                    message?(text: "This is your ship:\nThe USS Swashbuckler!") {
                        tutorialComponent.state = .thrusting
                    }
                    systemsManager?.configureTutorialThrusting()
                    playerCreator?.createPlayer(engine.gameStateComponent)
                    engine.playerEntity?.flash(3, endAlpha: 1.0)
                }
            case .thrusting:
                if engine.findEntity(named: .thrustButton) == nil {
                    shipButtonControlsCreator?.createThrustButton()
                    message?(text: "Try pressing and holding the thrust button to increase your speed.") {}
                } else if tutorialComponent.completionStatus[.thrusting] == .notStarted,
                          let x = engine.playerEntity![PositionComponent.self]?.x,
                          x > gameSize.halfWidth + gameSize.width / 5.0 {
                    tutorialComponent.completionStatus[.thrusting] = .completed
                    message?(text: "Feel the roar of the engines!") {
                        tutorialComponent.state = .flipping
                    }
                }
            // Continue updating other cases similarly...
            case .flipping:
                if engine.findEntity(named: .flipButton) == nil {
                    systemsManager?.configureTutorialTurning()
                    message?(text: "The Flip button flips your ship 180 degrees. \nTry flipping your ship.") {}
                    shipButtonControlsCreator?.createFlipButton()
                } else if tutorialComponent.completionStatus[.flipping] == .notStarted,
                          let button = engine.findEntity(named: .flipButton),
                          let flipCount = button[ButtonFlipComponent.self]?.tapCount,
                          flipCount > 0 {
                    tutorialComponent.completionStatus[.flipping] = .completed
                    message?(text: "Way to flip a ship!") {
                        tutorialComponent.state = .turning
                    }
                }
            // Continue updating other cases similarly...
            case .turning:
                if engine.findEntity(named: .leftButton) == nil,
                   engine.findEntity(named: .rightButton) == nil {
                    systemsManager?.configureTutorialTurning()
                    message?(text: "Now try turning with the left and right buttons.") {}
                    shipButtonControlsCreator?.createLeftButton()
                    shipButtonControlsCreator?.createRightButton()
                } else if tutorialComponent.completionStatus[.turning] == .notStarted,
                          let left = engine.findEntity(named: .leftButton),
                          let leftCount = left[ButtonLeftComponent.self]?.tapCount,
                          leftCount > 0,
                          let right = engine.findEntity(named: .rightButton),
                          let rightCount = right[ButtonRightComponent.self]?.tapCount,
                          rightCount > 0 {
                    tutorialComponent.completionStatus[.turning] = .completed
                    message?(text: "Nice turning!") {
                        tutorialComponent.state = .hud
                    }
                }
            // Continue updating other cases similarly...
            case .hud:
                if engine.findEntity(named: .hud) == nil {
                    systemsManager?.configureTutorialHUD()
                    engine.findEntity(named: .hud)?.flash(3, endAlpha: 1.0)
                    message?(text: "The HUD shows your remaining ships, score, and level.") {
                        tutorialComponent.state = .powerups
                    }
                }
            // Continue updating other cases similarly...
            case .powerups:
                if engine.findEntity(named: .fireButton) == nil,
                   engine.findEntity(named: .hyperspaceButton) == nil {
                    shipButtonControlsCreator?.createFireButton()
                    shipButtonControlsCreator?.createHyperspaceButton()
                    message?(text: """
                                  These are power-ups for torpedoes and hyperspace jumps.
                                  They'll appear soon after you run out.
                                  Try to get them to be able to fire and jump.
                                  """) {
                    }
                }
                if tutorialComponent.completionStatus[.powerups] == .notStarted,
                   let torpedoes = engine.playerEntity![GunComponent.self]?.numTorpedoes,
                   torpedoes > 0 {
                    tutorialComponent.completionStatus[.powerups] = .completed
                }
                if tutorialComponent.completionStatus[.powerups] == .notStarted,
                   let jumps = engine.playerEntity![HyperspaceDriveComponent.self]?.jumps,
                   jumps > 0 {
                    tutorialComponent.completionStatus[.powerups] = .completed
                }
                if tutorialComponent.completionStatus[.powerups] == .completed {
                    tutorialComponent.state = .tryHyperspace
                }
            // Continue updating other cases similarly...
            case .tryHyperspace:
                if tutorialComponent.completionStatus[.tryHyperspace] == .notStarted {
                    tutorialComponent.completionStatus[.tryHyperspace] = .completed
                    message?(text: "Try a hyperspace jump!") {}
                } else if let hyperspaceButton = engine.findEntity(named: .hyperspaceButton),
                          let tapCount = hyperspaceButton[ButtonHyperspaceComponent.self]?.tapCount,
                          tapCount > 0 {
                    tutorialComponent.state = .tryFiring
                }
            // Continue updating other cases similarly...
            case .tryFiring:
                if tutorialComponent.completionStatus[.tryFiring] == .notStarted {
                    tutorialComponent.completionStatus[.tryFiring] = .completed
                    message?(text: "Try firing a torpedo!") {}
                } else if let fireButton = engine.findEntity(named: .fireButton),
                          let tapCount = fireButton[ButtonFireComponent.self]?.tapCount,
                          tapCount > 0 {
                    tutorialComponent.state = .asteroid
                }
            // Continue updating other cases similarly...
            case .asteroid:
                if engine.getNodeList(nodeClassType: TorpedoCollisionNode.self).head == nil {
                    if tutorialComponent.completionStatus[.asteroid] == .notStarted {
                        tutorialComponent.completionStatus[.asteroid] = .completed
                        engine.add(system: SplitAsteroidSystem(asteroidCreator: asteroidCreator!,
                                                               treasureCreator: treasureCreator!), priority: .update)
                        engine.add(system: DeathThroesSystem(), priority: .update)
                        message?(text: "This is an asteroid.\nYour job is to mine treasures by shooting them.") {}
                        let asteroid = asteroidCreator?.createAsteroid(radius: AsteroidSize.small.rawValue,
                                                                       x: gameSize.halfWidth + gameSize.width / 6,
                                                                       y: gameSize.halfHeight,
                                                                       size: .small,
                                                                       level: 1)
                        // give it a treasure
                        asteroid?.remove(componentClass: TreasureInfoComponent.self)
                        asteroid?.add(component: TreasureInfoComponent(of: .standard))
                        asteroid?[VelocityComponent.self]?.linearVelocity = .zero
                        asteroid?[PositionComponent.self]?.point = CGPoint(x: gameSize.halfWidth + gameSize.width / 5,
                                                                           y: gameSize.halfHeight)
                        engine.playerEntity?[VelocityComponent.self]?.linearVelocity = .zero
                        engine.playerEntity?[PositionComponent.self]?.point = CGPoint(x: gameSize.halfWidth,
                                                                                      y: gameSize.halfHeight)
                        engine.playerEntity?[PositionComponent.self]?.rotationDegrees = 0.0
                    } else if engine.findEntity(named: "asteroidEntity_1") == nil,
                              tutorialComponent.completionStatus[.asteroid] == .completed {
                        tutorialComponent.completionStatus[.asteroid] = .completed
                        // asteroid has been destroyed in some manner
                        if engine.findEntity(named: .player) == nil || engine.findEntity(named: .player)!
                                                                             .has(componentClass: DeathThroesComponent.self) {
                            message?(text: "You don't get points for destroying asteroids that way!") { [unowned self] in
                                tutorialComponent.state = .treasure
                                playerCreator?.createPlayer(engine.gameStateComponent)
                            }
                        } else {
                            message?(text: "You just got some points!") {
                                tutorialComponent.state = .treasure
                            }
                        }
                    }
                }
            // Continue updating other cases similarly...
            case .treasure:
                if tutorialComponent.completionStatus[.treasure] == .notStarted {
                    tutorialComponent.completionStatus[.treasure] = .completed
                    message?(text: "That asteroid had a treasure in it!\nFly into it to collect it.") {}
                } else if engine.findEntity(named: "treasureEntity_1") == nil,
                          tutorialComponent.completionStatus[.treasure] == .completed {
                    tutorialComponent.state = .complete
                }
            // Continue updating other cases similarly...
            case .complete:
                message?(text: """
                              Training complete!
                              Enter the spiraling wormhole when you're ready to enter the asteroid field.
                              And be careful, you may not be alone out there...
                              """) {}
                let wormholeSprite = SwashScaledSpriteNode(imageNamed: "spiral")
                wormholeSprite.color = .yellow
                wormholeSprite.colorBlendFactor = 1.0
                let wormhole = Entity(named: "wormholeEntity")
                        .add(component: BridgeComponent())
                        .add(component: DisplayComponent(sknode: wormholeSprite))
                        .add(component: PositionComponent(x: gameSize.halfWidth, y: gameSize.halfHeight, z: .asteroids))
                        .add(component: CollidableComponent(radius: wormholeSprite.size.width / 2))
                        .add(component: VelocityComponent(velocityX: 0.0, velocityY: 0.0, angularVelocity: 100))
                wormholeSprite.entity = wormhole
                engine.add(entity: wormhole)
                tutorialComponent.state = .none
            case .none:
                break
        }
    }
}

class BridgeComponent: Component {}

class BridgeNode: Node {
    required init() {
        super.init()
        components = [
            BridgeComponent.name: nil,
            CollidableComponent.name: nil,
            PositionComponent.name: nil,
            VelocityComponent.name: nil,
        ]
    }
}

class MessageHandler {
    private let gameSize: CGSize
    private let tutorialText: Entity

    init(gameSize: CGSize, tutorialText: Entity) {
        self.gameSize = gameSize
        self.tutorialText = tutorialText
    }

    func callAsFunction(text: String, action: @escaping () -> Void) {
        tutorialText.remove(componentClass: PositionComponent.self)
        let skNode = tutorialText[DisplayComponent.self]!.sknode
        skNode.alpha = 1.0
        skNode.removeAllChildren()
        let label = createLabel(with: text)
        skNode.addChild(label)
        positionTutorialText(for: text)
        runMessageSequence(on: skNode, completion: action)
    }

    private func createLabel(with text: String) -> SKLabelNode {
        let label = SKLabelNode(attributedText: format(string: text))
        label.numberOfLines = 0
        return label
    }

    private func positionTutorialText(for text: String) {
        let y = gameSize.height - (24.0 * CGFloat((4 + text.components(separatedBy: "\n").count)))
        tutorialText.add(component: PositionComponent(x: gameSize.halfWidth, y: CGFloat(y), z: .top))
    }

    private func runMessageSequence(on node: SKNode, completion: @escaping () -> Void) {
        let wait3 = SKAction.wait(forDuration: 3)
        let wait2 = SKAction.wait(forDuration: 1)
        let fade = SKAction.fadeAlpha(to: 0.3, duration: 1)
        let seq = SKAction.sequence([wait3, fade, wait2])
        node.run(seq, completion: completion)
    }

    private func format(string: String) -> NSAttributedString {
        let attributed = NSMutableAttributedString(string: string)
        let range = NSRange(location: 0, length: attributed.length)
        let font = UIFont(name: "Futura Condensed Medium", size: 24.0)!
        let color = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        attributed.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
        attributed.addAttribute(NSAttributedString.Key.font, value: font, range: range)
        attributed.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        return NSAttributedString(attributedString: attributed)
    }
}