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

enum TutorialState {
    case thrusting
    case turning
    case flipping
    case hud
    case powerups
    case tryFiring
    case tryHyperspace
    case complete
    case none
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
                .add(component: TutorialComponent(tutorialState: .thrusting))
        engine.add(entity: tutorial)
    }
}

class TutorialComponent: Component {
    var state: TutorialState {
        didSet {
            print("\(oldValue) -> \(state)")
        }
    }
    
    // MARK: - Tutorial Progress in order
    var completedThrusting = false
    var completedFlipping = false
    var completedTurning = false
    var completedHud = false
    var completedPowerups = false
    var completedTorpedoPowerup = false
    var completedHyperspacePowerup = false
    var completedTryFiring = false
    var completedTryHyperspace = false
    
    init(tutorialState: TutorialState) {
        self.state = tutorialState
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

    init(systemsManager: SystemsManager,
         gameSize: CGSize,
         playerCreator: PlayerCreatorUseCase,
         shipButtonControlsCreator: ShipButtonCreatorUseCase) {
        self.systemsManager = systemsManager
        self.gameSize = gameSize
        self.playerCreator = playerCreator
        self.shipButtonControlsCreator = shipButtonControlsCreator
        super.init(nodeClass: TutorialNode.self)
        nodeUpdateFunction = updateNode
    }

    override func addToEngine(engine: Engine) {
        super.addToEngine(engine: engine)
        self.engine = engine
    }

    private func format(string: String) -> NSAttributedString {
        let attributed = NSMutableAttributedString(string: string)
        let range = NSRange(location: 0, length: attributed.length)
        let font = UIFont(name: "BadlocICG", size: 24.0)!
        let color = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        attributed.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
        attributed.addAttribute(NSAttributedString.Key.font, value: font, range: range)
        attributed.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        return NSAttributedString(attributedString: attributed)
    }

    private func updateNode(node: Node, time: TimeInterval) {
        guard let tutorialComponent = node[TutorialComponent.self]
        else { return }
        if engine.findEntity(named: .tutorialText) == nil {
            let skNode = SKNode()
            skNode.alpha = 1.0
            tutorialText = Entity(named: .tutorialText)
                    .add(component: DisplayComponent(sknode: skNode))
            engine.add(entity: tutorialText)
        }
        switch tutorialComponent.state {
            case .thrusting:
                if engine.findEntity(named: .thrustButton) == nil {
                    message(text: "This is your ship.\nTry pressing and holding the thrust button to increase your speed.") {}
                    systemsManager?.configureTutorialThrusting()
                    playerCreator?.createPlayer(engine.gameStateComponent)
                    shipButtonControlsCreator?.createThrustButton()
                } else if !tutorialComponent.completedThrusting,
                          let x = engine.playerEntity![PositionComponent.self]?.x,
                          x > gameSize.width / 2.0 + gameSize.width / 5.0 {
                    tutorialComponent.completedThrusting = true
                    message(text: "Feel the roar of the engines!") {
                        tutorialComponent.state = .flipping
                    }
                }
            case .flipping:
                if engine.findEntity(named: .flipButton) == nil {
                    systemsManager?.configureTutorialTurning()
                    message(text: "The Flip button flips your ship 180 degrees, it's good for slowing down.\nTry flipping your ship.") {}
                    shipButtonControlsCreator?.createFlipButton()
                } else if !tutorialComponent.completedFlipping,
                          let button = engine.findEntity(named: .flipButton),
                          let flipCount = button[ButtonFlipComponent.self]?.tapCount,
                          flipCount > 0 {
                    tutorialComponent.completedFlipping = true
                    message(text: "Way to flip a ship!") {
                        tutorialComponent.state = .turning
                    }
                }
            case .turning:
                if engine.findEntity(named: .leftButton) == nil,
                   engine.findEntity(named: .rightButton) == nil {
                    systemsManager?.configureTutorialTurning()
                    message(text: "Now try turning with the left and right buttons.") {}
                    shipButtonControlsCreator?.createLeftButton()
                    shipButtonControlsCreator?.createRightButton()
                } else if !tutorialComponent.completedTurning,
                          let left = engine.findEntity(named: .leftButton),
                          let leftCount = left[ButtonLeftComponent.self]?.tapCount,
                          leftCount > 0,
                          let right = engine.findEntity(named: .rightButton),
                          let rightCount = right[ButtonRightComponent.self]?.tapCount,
                          rightCount > 0 {
                    tutorialComponent.completedTurning = true
                    message(text: "Nice turning!") {
                        tutorialComponent.state = .hud
                    }
                }
            case .hud:
                if engine.findEntity(named: .hud) == nil {
                    systemsManager?.configureTutorialHUD()
                    engine.findEntity(named: .hud)?.flash(3, endAlpha: 1.0)
                    message(text: "The HUD shows your remaining ships, score, and level.") {
                        tutorialComponent.state = .powerups
                    }
                }
            case .powerups:
                if engine.findEntity(named: .fireButton) == nil,
                   engine.findEntity(named: .hyperspaceButton) == nil {
                    shipButtonControlsCreator?.createFireButton()
                    shipButtonControlsCreator?.createHyperspaceButton()
                    message(text: """
                                  These are power-ups for torpedoes and hyperspace jumps.
                                  They'll appear soon after you run out.
                                  Try to get them to be able to fire and jump.
                                  """) {
                    }
                }
                if !tutorialComponent.completedTorpedoPowerup,
                   let torpedoes = engine.playerEntity![GunComponent.self]?.numTorpedoes,
                   torpedoes > 0 {
                    tutorialComponent.completedTorpedoPowerup = true
                }
                if !tutorialComponent.completedHyperspacePowerup,
                   let jumps = engine.playerEntity![HyperspaceDriveComponent.self]?.jumps,
                   jumps > 0 {
                    tutorialComponent.completedHyperspacePowerup = true
                }
                if tutorialComponent.completedTorpedoPowerup && tutorialComponent.completedHyperspacePowerup {
                    tutorialComponent.state = .tryFiring
                }
            case .tryFiring:
                if !tutorialComponent.completedTryFiring {
                    tutorialComponent.completedTryFiring = true
                    message(text: "Try firing a torpedo!") {}
                } else if let fireButton = engine.findEntity(named: .fireButton),
                   let tapCount = fireButton[ButtonFireComponent.self]?.tapCount,
                   tapCount > 0 {
                    tutorialComponent.state = .tryHyperspace
                }
            case .tryHyperspace:
                if !tutorialComponent.completedTryHyperspace {
                    tutorialComponent.completedTryHyperspace = true
                    message(text: "Try a hyperspace jump!") {}
                } else if let hyperspaceButton = engine.findEntity(named: .hyperspaceButton),
                   let tapCount = hyperspaceButton[ButtonHyperspaceComponent.self]?.tapCount,
                   tapCount > 0 {
                    tutorialComponent.state = .complete
                }
            case .complete:
                message(text: "Tutorial complete!\nYou're ready to play!") {}
                tutorialComponent.state = .none
            case .none:
                break
        }
    }

    private func message(text: String, action: @escaping () -> Void) {
        tutorialText.remove(componentClass: PositionComponent.self)
        let skNode = tutorialText[DisplayComponent.self]!.sknode
        skNode.alpha = 1.0
        skNode.removeAllChildren()
        let label = SKLabelNode(attributedText: format(string: text))
        label.numberOfLines = 0
        skNode.addChild(label)
        //
        let y = gameSize.height - (24.0 * CGFloat((4 + text.components(separatedBy: "\n").count)))
        tutorialText
                .add(component: PositionComponent(x: gameSize.width / 2.0, y: CGFloat(y), z: .top))
        //
        let wait3 = SKAction.wait(forDuration: 3)
        let wait2 = SKAction.wait(forDuration: 2)
        let fade = SKAction.fadeAlpha(to: 0.3, duration: 0.25)
        let seq = SKAction.sequence([wait3, fade, wait2])
        skNode.run(seq, completion: action)
    }
}
