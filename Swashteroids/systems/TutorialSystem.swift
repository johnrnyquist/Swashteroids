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
import Foundation
import SpriteKit

enum TutorialStep: CaseIterable {
    case welcome
    case thisIsYourShip
    case thrusting1
    case thrusting2
    case turning1
    case turning2
    case flipping1
    case flipping2
    case hud
    case powerups1
    case powerups2
    case torpedoPowerup
    case hyperspacePowerup
    case tryFiring1
    case tryFiring2
    case tryHyperspace1
    case tryHyperspace2
    case asteroid
    case asteroid1
    case asteroid2
    case treasure1
    case treasure2
    case complete
    case none
}

enum TutorialStepCompletionStatus {
    case notStarted
    case completed
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

class WarpTunnelComponent: Component {}

class WarpTunnelNode: Node {
    required init() {
        super.init()
        components = [
            WarpTunnelComponent.name: nil,
            CollidableComponent.name: nil,
            PositionComponent.name: nil,
            VelocityComponent.name: nil,
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
            .thrusting1: handleThrusting1,
            .thrusting2: handleThrusting2,
            .turning1: handleTurning1,
            .turning2: handleTurning2,
            .flipping1: handleFlipping1,
            .flipping2: handleFlipping2,
            .hud: handleHUD,
            .powerups1: handlePowerups1,
            .powerups2: handlePowerups2,
            .tryFiring1: handleTryFiring1,
            .tryFiring2: handleTryFiring2,
            .tryHyperspace1: handleTryHyperspace1,
            .tryHyperspace2: handleTryHyperspace2,
            .asteroid: handleAsteroid,
            .treasure1: handleTreasure1,
            .treasure2: handleTreasure2,
            .complete: handleComplete
        ]
    }

    var node: Node?

    private func updateNode(node: Node, time: TimeInterval) {
        guard let tutorialComponent = node[TutorialComponent.self] else { return }
        self.node = node
        tutorialActions[tutorialComponent.state]?(tutorialComponent)
    }

    private func handleWelcome(_ tutorialComponent: TutorialComponent) {
        guard tutorialComponent.completionStatus[.welcome] == .notStarted else { return }
        tutorialComponent.completionStatus[.welcome] = .completed
        node?.entity?
             .add(component: AudioComponent(asset: .tut_welcome))
        message?(text: """
                       Welcome aboard, Captain!
                       Here you’ll learn to mine asteroids for treasures!
                       """) {
            tutorialComponent.state = .thisIsYourShip
        }
    }

    private func handleThisIsYourShip(_ tutorialComponent: TutorialComponent) {
        guard tutorialComponent.completionStatus[.thisIsYourShip] == .notStarted else { return }
        tutorialComponent.completionStatus[.thisIsYourShip] = .completed
        node?.entity?
             .add(component: AudioComponent(asset: .tut_this_is_your_ship))
        message?(text: """
                       This is your ship:
                       The USS Swashbuckler!
                       """) {
            tutorialComponent.state = .thrusting1
        }
        systemsManager?.configureTutorialThrusting()
        playerCreator?.createPlayer(engine.gameStateComponent)
        engine.playerEntity?.flash(3, endAlpha: 1.0)
    }

    private func handleThrusting1(_ tutorialComponent: TutorialComponent) {
        guard tutorialComponent.completionStatus[.thrusting1] == .notStarted else { return }
        tutorialComponent.completionStatus[.thrusting1] = .completed
        shipButtonControlsCreator?.createThrustButton()
        node?.entity?
             .add(component: AudioComponent(asset: .tut_try_thrust))
        message?(text: "Try pressing and holding the thrust button to increase your speed.") {
            tutorialComponent.state = .thrusting2
        }
    }

    private func handleThrusting2(_ tutorialComponent: TutorialComponent) {
        guard tutorialComponent.completionStatus[.thrusting2] == .notStarted,
              let playerPositionX = engine.playerEntity?[PositionComponent.self]?.x,
              playerPositionX > gameSize.halfWidth + gameSize.width / 5.0 || playerPositionX < gameSize.halfWidth
        else { return }
        tutorialComponent.completionStatus[.thrusting2] = .completed
        node?.entity?.add(component: AudioComponent(asset: .tut_feel_the_roar))
        message?(text: "Feel the roar of the engines!") {
            tutorialComponent.state = .flipping1
        }
    }

    private func handleFlipping1(_ tutorialComponent: TutorialComponent) {
        guard tutorialComponent.completionStatus[.flipping1] == .notStarted else { return }
        tutorialComponent.completionStatus[.flipping1] = .completed
        systemsManager?.configureTutorialTurning()
        node?.entity?
             .add(component: AudioComponent(asset: .tut_flipping))
        message?(text: """
                       The Flip button flips your ship 180 degrees.
                       Try flipping your ship.
                       """) {
            self.shipButtonControlsCreator?.createFlipButton()
            tutorialComponent.state = .flipping2
        }
    }

    private func handleFlipping2(_ tutorialComponent: TutorialComponent) {
        guard tutorialComponent.completionStatus[.flipping2] == .notStarted,
              let button = engine.findEntity(named: .flipButton),
              let flipCount = button[ButtonFlipComponent.self]?.tapCount,
              flipCount > 0
        else { return }
        tutorialComponent.completionStatus[.flipping2] = .completed
        node?.entity?
             .add(component: AudioComponent(asset: .tut_way_to_flip))
        message?(text: "Way to flip a ship!", wait2: 1) {
            tutorialComponent.state = .turning1
        }
    }

    private func handleTurning1(_ tutorialComponent: TutorialComponent) {
        guard tutorialComponent.completionStatus[.turning1] == .notStarted else { return }
        tutorialComponent.completionStatus[.turning1] = .completed
        systemsManager?.configureTutorialTurning()
        shipButtonControlsCreator?.createLeftButton()
        shipButtonControlsCreator?.createRightButton()
        node?.entity?
             .add(component: AudioComponent(asset: .tut_left_right))
        message?(text: "Now try turning with the left and right buttons.") {
            tutorialComponent.state = .turning2
        }
    }

    private func handleTurning2(_ tutorialComponent: TutorialComponent) {
        guard tutorialComponent.completionStatus[.turning2] == .notStarted,
              let left = engine.findEntity(named: .leftButton),
              let leftCount = left[ButtonLeftComponent.self]?.tapCount,
              leftCount > 0,
              let right = engine.findEntity(named: .rightButton),
              let rightCount = right[ButtonRightComponent.self]?.tapCount,
              rightCount > 0
        else { return }
        tutorialComponent.completionStatus[.turning2] = .completed
        node?.entity?
             .add(component: AudioComponent(asset: .tut_nice_turning))
        message?(text: "Nice turning!") {
            tutorialComponent.state = .hud
        }
    }

    private func handleHUD(_ tutorialComponent: TutorialComponent) {
        guard tutorialComponent.completionStatus[.hud] == .notStarted else { return }
        tutorialComponent.completionStatus[.hud] = .completed
        systemsManager?.configureTutorialHUD()
        engine.findEntity(named: .hud)?.flash(3, endAlpha: 1.0)
        node?.entity?.add(component: AudioComponent(asset: .tut_this_is_your_hud))
        message?(text: "The HUD shows your remaining ships, score, and level.") {
            tutorialComponent.state = .powerups1
        }
    }

    private func handlePowerups1(_ tutorialComponent: TutorialComponent) {
        guard tutorialComponent.completionStatus[.powerups1] == .notStarted else { return }
        tutorialComponent.completionStatus[.powerups1] = .completed
        shipButtonControlsCreator?.createFireButton()
        shipButtonControlsCreator?.createHyperspaceButton()
        node?.entity?
             .add(component: AudioComponent(asset: .tut_these_are_the_powerups))
        message?(text: """
                       These are power-ups for torpedoes and hyperspace jumps.
                       They'll appear soon after you run out.
                       Try to get them to be able to fire and jump.
                       """) {
            tutorialComponent.state = .powerups2
        }
    }

    private func handlePowerups2(_ tutorialComponent: TutorialComponent) {
        // has the torpedo powerup been captured?
        if tutorialComponent.completionStatus[.torpedoPowerup] == .notStarted,
           let torpedoes = engine.playerEntity![GunComponent.self]?.numTorpedoes,
           torpedoes > 0 {
            tutorialComponent.completionStatus[.torpedoPowerup] = .completed
        }
        // has the hyperspace powerup been captured?
        if tutorialComponent.completionStatus[.hyperspacePowerup] == .notStarted,
           let jumps = engine.playerEntity![HyperspaceDriveComponent.self]?.jumps,
           jumps > 0 {
            tutorialComponent.completionStatus[.hyperspacePowerup] = .completed
        }
        // have both powerups been captured?
        if tutorialComponent.completionStatus[.torpedoPowerup] == .completed &&
           tutorialComponent.completionStatus[.hyperspacePowerup] == .completed {
            // user might tap before we tell them to
            if let fireButton = engine.findEntity(named: .fireButton),
               let tapCount = fireButton[ButtonFireComponent.self]?.tapCount,
               tapCount == 0 {
                tutorialComponent.state = .tryFiring1
            } else if let hyperspaceButton = engine.findEntity(named: .hyperspaceButton),
                      let tapCount = hyperspaceButton[ButtonHyperspaceComponent.self]?.tapCount,
                      tapCount == 0 {
                tutorialComponent.state = .tryHyperspace1
            } else {
                tutorialComponent.state = .asteroid
            }
        }
    }

    private func handleTryFiring1(_ tutorialComponent: TutorialComponent) {
        guard tutorialComponent.completionStatus[.tryFiring1] == .notStarted else { return }
        tutorialComponent.completionStatus[.tryFiring1] = .completed
        node?.entity?
             .add(component: AudioComponent(asset: .tut_try_firing))
        message?(text: "Try firing a torpedo!") {
            tutorialComponent.state = .tryFiring2
        }
    }

    private func handleTryFiring2(_ tutorialComponent: TutorialComponent) {
        if let fireButton = engine.findEntity(named: .fireButton),
           let tapCount = fireButton[ButtonFireComponent.self]?.tapCount,
           tapCount > 0 {
            tutorialComponent.state = .tryHyperspace1
        }
    }

    private func handleTryHyperspace1(_ tutorialComponent: TutorialComponent) {
        guard tutorialComponent.completionStatus[.tryHyperspace1] == .notStarted else { return }
        tutorialComponent.completionStatus[.tryHyperspace1] = .completed
        node?.entity?
             .add(component: AudioComponent(asset: .tut_try_hyperspace))
        message?(text: "Try a hyperspace jump!") {
            tutorialComponent.state = .tryHyperspace2
        }
    }

    private func handleTryHyperspace2(_ tutorialComponent: TutorialComponent) {
        guard tutorialComponent.completionStatus[.tryHyperspace2] == .notStarted,
              let hyperspaceButton = engine.findEntity(named: .hyperspaceButton),
              let tapCount = hyperspaceButton[ButtonHyperspaceComponent.self]?.tapCount,
              tapCount > 0
        else { return }
        tutorialComponent.completionStatus[.tryHyperspace2] = .completed
        message?(text: " ", wait1: 0, fade: 1, wait2: 0) {
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
                node?.entity?
                     .add(component: AudioComponent(asset: .tut_this_is_an_asteroid))
                message?(text: """
                               This is an asteroid.
                               Your job is to mine treasures by shooting them.
                               """) {}
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
                let player = engine.findEntity(named: .player)
                if player == nil || player!.has(componentClass: DeathThroesComponent.self) {
                    node?.entity?
                         .add(component: AudioComponent(asset: .tut_no_points))
                    message?(text: "You don't get points for destroying an asteroid that way!") { [unowned self] in
                        tutorialComponent.state = .treasure1
                        playerCreator?.createPlayer(engine.gameStateComponent)
                    }
                } else {
                    node?.entity?
                         .add(component: AudioComponent(asset: .tut_got_points))
                    message?(text: "You just got some points!", wait1: 0, fade: 0, wait2: 2) {
                        tutorialComponent.state = .treasure1
                    }
                }
            }
        }
    }

    private func handleTreasure1(_ tutorialComponent: TutorialComponent) {
        guard tutorialComponent.completionStatus[.treasure1] == .notStarted else { return }
        tutorialComponent.completionStatus[.treasure1] = .completed
        node?.entity?
             .add(component: AudioComponent(asset: .tut_collect_treasure))
        message?(text: """
                       That asteroid had a treasure in it!
                       Fly into it to collect it.
                       """) {
            tutorialComponent.state = .treasure2
        }
    }

    private func handleTreasure2(_ tutorialComponent: TutorialComponent) {
        guard tutorialComponent.completionStatus[.treasure2] == .notStarted else { return }
        if engine.findEntity(named: "treasureEntity_1") == nil {
            tutorialComponent.completionStatus[.treasure2] = .completed
            tutorialComponent.state = .complete
        }
    }

    private func handleComplete(_ tutorialComponent: TutorialComponent) {
        node?.entity?
             .add(component: AudioComponent(asset: .tut_congratulations))
        message?(text: """
                       Congratulations! You’ve completed the training!
                       Enter the warp tunnel when you're ready to enter the asteroid field.
                       And be careful, you may not be alone out there...
                       """) {}
        let tunnelSprite = SwashScaledSpriteNode(imageNamed: "spiral")
        tunnelSprite.color = .yellow
        tunnelSprite.colorBlendFactor = 1.0
        let tunnel = Entity(named: "tunnelEntity")
                .add(component: WarpTunnelComponent())
                .add(component: DisplayComponent(sknode: tunnelSprite))
                .add(component: PositionComponent(x: gameSize.halfWidth, y: gameSize.halfHeight, z: .asteroids))
                .add(component: CollidableComponent(radius: tunnelSprite.size.width / 2))
                .add(component: VelocityComponent(velocityX: 0.0, velocityY: 0.0, angularVelocity: 100))
        tunnelSprite.swashEntity = tunnel
        engine.add(entity: tunnel)
        tutorialComponent.state = .none
    }
}

