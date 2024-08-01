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
import SwiftySound

enum TutorialStep: CaseIterable {
    case welcome
    case thisIsYourShip
    case thrusting
    case turning
    case flipping
    case hud
    case powerups
    case torpedoPowerup
    case hyperspacePowerup
    case tryFiring
    case tryHyperspace
    case asteroid
    case asteroid1
    case asteroid2
    case treasure
    case complete
    case none
}

enum TutorialStepCompletionStatus {
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
                .add(component: TutorialComponent())
        engine.add(entity: tutorial)
    }
}

class TutorialComponent: Component {
    var state: TutorialStep
    var completionStatus: [TutorialStep: TutorialStepCompletionStatus]

    init(tutorialState: TutorialStep = .welcome) {
        state = tutorialState
        completionStatus = Dictionary(uniqueKeysWithValues: TutorialStep.allCases.map { ($0, .notStarted) })
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
    private var message: TutorialMessageHandler?
    private var tutorialActions: [TutorialStep: (TutorialComponent) -> Void] = [:]

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
        setupTutorialActions()
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
        message = TutorialMessageHandler(gameSize: gameSize, tutorialText: tutorialText)
    }

    private func setupTutorialActions() {
        tutorialActions = [
            .welcome: handleWelcome,
            .thisIsYourShip: handleThisIsYourShip,
            .thrusting: handleThrusting,
            .turning: handleTurning,
            .flipping: handleFlipping,
            .hud: handleHUD,
            .powerups: handlePowerups,
            .tryFiring: handleTryFiring,
            .tryHyperspace: handleTryHyperspace,
            .asteroid: handleAsteroid,
            .treasure: handleTreasure,
            .complete: handleComplete
        ]
    }

    private func updateNode(node: Node, time: TimeInterval) {
        guard let tutorialComponent = node[TutorialComponent.self] else { return }
        tutorialActions[tutorialComponent.state]?(tutorialComponent)
    }

    private func handleWelcome(_ tutorialComponent: TutorialComponent) {
        if tutorialComponent.completionStatus[.welcome] == .notStarted {
            tutorialComponent.completionStatus[.welcome] = .completed
            Sound.play(file: "welcome.mp3")
            message?(text: "Welcome aboard, Captain!\nHere you’ll learn to mine asteroids for treasures!") {
                tutorialComponent.state = .thisIsYourShip
            }
        }
    }

    private func handleThisIsYourShip(_ tutorialComponent: TutorialComponent) {
        guard tutorialComponent.completionStatus[.thisIsYourShip] == .notStarted else { return }
        tutorialComponent.completionStatus[.thisIsYourShip] = .completed
        Sound.play(file: "this_is_your_ship.mp3")
        message?(text: "This is your ship:\nThe USS Swashbuckler!") {
            tutorialComponent.state = .thrusting
        }
        systemsManager?.configureTutorialThrusting()
        playerCreator?.createPlayer(engine.gameStateComponent)
        engine.playerEntity?.flash(3, endAlpha: 1.0)
    }

    private func handleThrusting(_ tutorialComponent: TutorialComponent) {
        if engine.findEntity(named: .thrustButton) == nil {
            shipButtonControlsCreator?.createThrustButton()
            Sound.play(file: "try_thrust.mp3")
            message?(text: "Try pressing and holding the thrust button to increase your speed.") {}
        } else if tutorialComponent.completionStatus[.thrusting] == .notStarted,
                  let x = engine.playerEntity![PositionComponent.self]?.x,
                  x > gameSize.halfWidth + gameSize.width / 5.0 {
            tutorialComponent.completionStatus[.thrusting] = .completed
            Sound.play(file: "feel.mp3")
            message?(text: "Feel the roar of the engines!") {
                tutorialComponent.state = .flipping
            }
        }
    }

    private func handleFlipping(_ tutorialComponent: TutorialComponent) {
        if engine.findEntity(named: .flipButton) == nil {
            systemsManager?.configureTutorialTurning()
            Sound.play(file: "flipping.mp3")
            message?(text: """
                           The Flip button flips your ship 180 degrees.
                           Try flipping your ship.
                           """) {}
            shipButtonControlsCreator?.createFlipButton()
        } else if tutorialComponent.completionStatus[.flipping] == .notStarted,
                  let button = engine.findEntity(named: .flipButton),
                  let flipCount = button[ButtonFlipComponent.self]?.tapCount,
                  flipCount > 0 {
            tutorialComponent.completionStatus[.flipping] = .completed
            Sound.play(file: "way_to_flip.mp3")
            message?(text: "Way to flip a ship!") {
                tutorialComponent.state = .turning
            }
        }
    }

    private func handleTurning(_ tutorialComponent: TutorialComponent) {
        if engine.findEntity(named: .leftButton) == nil,
           engine.findEntity(named: .rightButton) == nil {
            systemsManager?.configureTutorialTurning()
            Sound.play(file: "left_right.mp3")
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
            Sound.play(file: "nice_turning.mp3")
            message?(text: "Nice turning!") {
                tutorialComponent.state = .hud
            }
        }
    }

    private func handleHUD(_ tutorialComponent: TutorialComponent) {
        if engine.findEntity(named: .hud) == nil {
            systemsManager?.configureTutorialHUD()
            engine.findEntity(named: .hud)?.flash(3, endAlpha: 1.0)
            Sound.play(file: "hud.mp3")
            message?(text: "The HUD shows your remaining ships, score, and level.") {
                tutorialComponent.state = .powerups
            }
        }
    }

    private func handlePowerups(_ tutorialComponent: TutorialComponent) {
        if engine.findEntity(named: .fireButton) == nil,
           engine.findEntity(named: .hyperspaceButton) == nil {
            shipButtonControlsCreator?.createFireButton()
            shipButtonControlsCreator?.createHyperspaceButton()
            Sound.play(file: "these_are_the_powerups.mp3")
            message?(text: """
                           These are power-ups for torpedoes and hyperspace jumps.
                           They'll appear soon after you run out.
                           Try to get them to be able to fire and jump.
                           """) {
            }
        }
        if tutorialComponent.completionStatus[.torpedoPowerup] == .notStarted,
           let torpedoes = engine.playerEntity![GunComponent.self]?.numTorpedoes,
           torpedoes > 0 {
            tutorialComponent.completionStatus[.torpedoPowerup] = .completed
        }
        if tutorialComponent.completionStatus[.hyperspacePowerup] == .notStarted,
           let jumps = engine.playerEntity![HyperspaceDriveComponent.self]?.jumps,
           jumps > 0 {
            tutorialComponent.completionStatus[.hyperspacePowerup] = .completed
        }
        if tutorialComponent.completionStatus[.torpedoPowerup] == .completed &&
           tutorialComponent.completionStatus[.hyperspacePowerup] == .completed {
            if let fireButton = engine.findEntity(named: .fireButton),
               let tapCount = fireButton[ButtonFireComponent.self]?.tapCount,
               tapCount == 0 {
                tutorialComponent.state = .tryFiring
            } else if let hyperspaceButton = engine.findEntity(named: .hyperspaceButton),
                      let tapCount = hyperspaceButton[ButtonHyperspaceComponent.self]?.tapCount,
                      tapCount == 0 {
                tutorialComponent.state = .tryHyperspace
            } else {
                tutorialComponent.state = .asteroid
            }
        }
    }

    private func handleTryFiring(_ tutorialComponent: TutorialComponent) {
        if tutorialComponent.completionStatus[.tryFiring] == .notStarted {
            tutorialComponent.completionStatus[.tryFiring] = .completed
            Sound.play(file: "try_firing.mp3")
            message?(text: "Try firing a torpedo!") {}
        } else if let fireButton = engine.findEntity(named: .fireButton),
                  let tapCount = fireButton[ButtonFireComponent.self]?.tapCount,
                  tapCount > 0 {
            tutorialComponent.state = .tryHyperspace
        }
    }

    private func handleTryHyperspace(_ tutorialComponent: TutorialComponent) {
        if tutorialComponent.completionStatus[.tryHyperspace] == .notStarted {
            tutorialComponent.completionStatus[.tryHyperspace] = .completed
            Sound.play(file: "try_hyperspace.mp3")
            message?(text: "Try a hyperspace jump!") {}
        } else if let hyperspaceButton = engine.findEntity(named: .hyperspaceButton),
                  let tapCount = hyperspaceButton[ButtonHyperspaceComponent.self]?.tapCount,
                  tapCount > 0 {
            tutorialComponent.state = .asteroid
        }
    }

    private func handleAsteroid(_ tutorialComponent: TutorialComponent) {
        if engine.getNodeList(nodeClassType: TorpedoCollisionNode.self).head == nil {
            if tutorialComponent.completionStatus[.asteroid1] == .notStarted {
                tutorialComponent.completionStatus[.asteroid1] = .completed
                engine.add(system: SplitAsteroidSystem(asteroidCreator: asteroidCreator!,
                                                       treasureCreator: treasureCreator!), priority: .update)
                engine.add(system: DeathThroesSystem(), priority: .update)
                Sound.play(file: "this_is_an_asteroid.mp3")
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
                      tutorialComponent.completionStatus[.asteroid2] == .notStarted {
                tutorialComponent.completionStatus[.asteroid2] = .completed
                // asteroid has been destroyed in some manner
                if engine.findEntity(named: .player) == nil || engine.findEntity(named: .player)!
                                                                     .has(componentClass: DeathThroesComponent.self) {
                    Sound.play(file: "no_points.mp3")
                    message?(text: "You don't get points for destroying asteroids that way!") { [unowned self] in
                        tutorialComponent.state = .treasure
                        playerCreator?.createPlayer(engine.gameStateComponent)
                    }
                } else {
                    Sound.play(file: "got_points.mp3")
                    message?(text: "You just got some points!") {
                        tutorialComponent.state = .treasure
                    }
                }
            }
        }
    }

    private func handleTreasure(_ tutorialComponent: TutorialComponent) {
        if tutorialComponent.completionStatus[.treasure] == .notStarted {
            tutorialComponent.completionStatus[.treasure] = .completed
            Sound.play(file: "collect_treasure.mp3")
            message?(text: "That asteroid had a treasure in it!\nFly into it to collect it.") {}
        } else if engine.findEntity(named: "treasureEntity_1") == nil,
                  tutorialComponent.completionStatus[.treasure] == .completed {
            tutorialComponent.state = .complete
        }
    }

    private func handleComplete(_ tutorialComponent: TutorialComponent) {
        Sound.play(file: "congratulations.mp3")
        message?(text: """
                       Congratulations! You’ve completed the training!
                       Enter the warp tunnel when you're ready to enter the asteroid field.
                       And be careful, you may not be alone out there...
                       """) {}
        let tunnelSprite = SwashScaledSpriteNode(imageNamed: "spiral")
        tunnelSprite.color = .yellow
        tunnelSprite.colorBlendFactor = 1.0
        let tunnel = Entity(named: "tunnelEntity")
                .add(component: BridgeComponent())
                .add(component: DisplayComponent(sknode: tunnelSprite))
                .add(component: PositionComponent(x: gameSize.halfWidth, y: gameSize.halfHeight, z: .asteroids))
                .add(component: CollidableComponent(radius: tunnelSprite.size.width / 2))
                .add(component: VelocityComponent(velocityX: 0.0, velocityY: 0.0, angularVelocity: 100))
        tunnelSprite.entity = tunnel
        engine.add(entity: tunnel)
        tutorialComponent.state = .none
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

