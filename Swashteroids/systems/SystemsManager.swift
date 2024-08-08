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

extension Engine {
    func remove(systemType: System.Type) {
        systems.forEach { system in
            if type(of: system) == systemType {
                remove(system: system)
            }
        }
    }
}

final class SystemsManager {
    private let engine: Engine
    private let creatorManager: CreatorsManager
    private(set) var transitionAppStateSystem: TransitionAppStateSystem?
    private let size: CGSize

    init(engine: Engine, creatorManager: CreatorsManager, size: CGSize) {
        self.engine = engine
        self.creatorManager = creatorManager
        self.size = size
    }

    func configureTutorialThrusting() {
        // These are what we need:
        //        AlertPresentingSystem
        //        AudioSystem
        //        DisplaySystem
        //        FlipSystem
        //        MovementSystem
        //        NacellesSystem
        //        RepeatingAudioSystem
        //        ShipControlsSystem
        //        ThrustSystem
        //        TouchedButtonSystem
        //        TransitionAppStateSystem
        //        TurnLeftSystem
        //        TurnRightSystem
        //        TutorialSystem
        // For now, we subtract from what we have
        engine.remove(systemType: AccelerometerSystem.self)
        engine.remove(systemType: AlienAppearancesSystem.self)
        engine.remove(systemType: AlienFiringSystem.self)
        engine.remove(systemType: AnimationSystem.self)
        engine.remove(systemType: CollisionSystem.self)
        engine.remove(systemType: CreateShieldPowerUpSystem.self)
        engine.remove(systemType: CreateXRayPowerUpSystem.self)
        engine.remove(systemType: DeathThroesSystem.self)
        engine.remove(systemType: ExitScreenSystem.self)
        engine.remove(systemType: FiringSystem.self)
        engine.remove(systemType: GameOverSystem.self)
        engine.remove(systemType: GameOverCheckSystem.self)
        engine.remove(systemType: HudSystem.self)
        engine.remove(systemType: HyperspaceJumpSystem.self)
        engine.remove(systemType: LevelManagementSystem.self)
        engine.remove(systemType: LifetimeSystem.self)
        engine.remove(systemType: MoveToTargetSystem.self)
        engine.remove(systemType: PickTargetSystem.self)
        engine.remove(systemType: AlienReactionTimeSystem.self)
        engine.remove(systemType: ShieldSystem.self)
        engine.remove(systemType: SplitAsteroidSystem.self)
        engine.remove(systemType: TimePlayedSystem.self)
        engine.remove(systemType: TouchedQuadrantSystem.self)
        engine.remove(systemType: XRayVisionSystem.self)
    }

    func configureTutorialTurning() {}

    func configureTutorialHUD() {
        engine.add(system: HudSystem(powerUpCreator: creatorManager.powerUpCreator), priority: .update)
              .add(system: HyperspaceJumpSystem(), priority: .preUpdate)
              .add(system: FiringSystem(torpedoCreator: creatorManager.torpedoCreator), priority: .preUpdate)
              .add(system: CollisionSystem(shipCreator: creatorManager.playerCreator,
                                           asteroidCreator: creatorManager.asteroidCreator,
                                           shipButtonControlsCreator: creatorManager.shipButtonControlsCreator,
                                           gameSize: size),
                   priority: .resolveCollisions)
        creatorManager.hudCreator.createHud(gameState: engine.gameStateComponent)
    }

    func configureGameSystems(scene: GameScene, alertPresenter: PauseAlertPresenting, touchManager: TouchManager) {
        let transition = PlayingTransition(
            hudCreator: creatorManager.hudCreator,
            toggleShipControlsCreator: creatorManager.toggleShipControlsCreator,
            shipControlQuadrantsCreator: creatorManager.shipControlQuadrantsCreator,
            shipButtonControlsCreator: creatorManager.shipButtonControlsCreator)
        let startTransition = StartTransition(engine: engine, startScreenCreator: creatorManager.startScreenCreator)
        let gameOverTransition = GameOverTransition(engine: engine, alert: alertPresenter)
        let tutorialTransition = TutorialTransition(engine: engine)
        transitionAppStateSystem = TransitionAppStateSystem(startTransition: startTransition,
                                                            playingTransition: transition,
                                                            gameOverTransition: gameOverTransition,
                                                            tutorialTransition: tutorialTransition)
        engine
            // preupdate
                .add(system: StartNewGameSystem(alertPresenter: alertPresenter), priority: .preUpdate)
                .add(system: transitionAppStateSystem!, priority: .preUpdate)
                .add(system: TouchedButtonSystem(touchManager: touchManager), priority: .preUpdate)
                .add(system: TouchedQuadrantSystem(touchManager: touchManager), priority: .preUpdate)
                .add(system: AlertPresentingSystem(alertPresenting: alertPresenter), priority: .preUpdate)
                .add(system: HyperspaceJumpSystem(), priority: .preUpdate)
                .add(system: FiringSystem(torpedoCreator: creatorManager.torpedoCreator), priority: .preUpdate)
                .add(system: FlipSystem(), priority: .preUpdate)
                .add(system: TurnLeftSystem(), priority: .preUpdate)
                .add(system: TurnRightSystem(), priority: .preUpdate)
                .add(system: ThrustSystem(), priority: .preUpdate)
                .add(system: TimePlayedSystem(), priority: .preUpdate)
                .add(system: ShipCreationSystem(playerCreator: creatorManager.playerCreator, gameSize: scene.size),
                     priority: .preUpdate)
                .add(system: GameOverCheckSystem(), priority: .preUpdate)
                .add(system: GameOverSystem(), priority: .preUpdate)
                .add(system: ShipControlsSystem(toggleShipControlsCreator: creatorManager.toggleShipControlsCreator,
                                                shipControlQuadrantsCreator: creatorManager.shipControlQuadrantsCreator,
                                                shipButtonControlsCreator: creatorManager.shipButtonControlsCreator,
                                                startButtonsCreator: creatorManager.startScreenCreator),
                     priority: .update)
                // update
                .add(system: TutorialSystem(systemsManager: self,
                                            gameSize: scene.size,
                                            playerCreator: creatorManager.playerCreator,
                                            shipButtonControlsCreator: creatorManager.shipButtonControlsCreator,
                                            asteroidCreator: creatorManager.asteroidCreator,
                                            treasureCreator: creatorManager.treasureCreator),
                     priority: .update)
                .add(system: CreateShieldPowerUpSystem(powerUpCreator: creatorManager.powerUpCreator), priority: .update)
                .add(system: CreateXRayPowerUpSystem(powerUpCreator: creatorManager.powerUpCreator), priority: .update)
                .add(system: AlienAppearancesSystem(alienCreator: creatorManager.alienCreator), priority: .update)
                .add(system: LifetimeSystem(), priority: .update)
                .add(system: AlienReactionTimeSystem(), priority: .update)
                .add(system: PickTargetSystem(), priority: .update)
                .add(system: MoveToTargetSystem(), priority: .update)
                .add(system: ExitScreenSystem(), priority: .update)
                .add(system: AlienFiringSystem(torpedoCreator: creatorManager.torpedoCreator, gameSize: scene.size),
                     priority: .update)
                .add(system: DeathThroesSystem(), priority: .update)
                .add(system: NacellesSystem(), priority: .update)
                .add(system: HudSystem(powerUpCreator: creatorManager.powerUpCreator), priority: .update)
                .add(system: SplitAsteroidSystem(asteroidCreator: creatorManager.asteroidCreator,
                                                 treasureCreator: creatorManager.treasureCreator),
                     priority: .update)
                .add(system: LevelManagementSystem(asteroidCreator: creatorManager.asteroidCreator, scene: scene),
                     priority: .update)
                // move
                .add(system: AccelerometerSystem(), priority: .move)
                .add(system: MovementSystem(gameSize: scene.size), priority: .move)
                .add(system: ShieldSystem(), priority: .move)
                // resolve collisions
                .add(system: CollisionSystem(shipCreator: creatorManager.playerCreator,
                                             asteroidCreator: creatorManager.asteroidCreator,
                                             shipButtonControlsCreator: creatorManager.shipButtonControlsCreator,
                                             gameSize: scene.size),
                     priority: .resolveCollisions)
                // animate
                .add(system: AnimationSystem(), priority: .animate)
                // render
                .add(system: AudioSystem(), priority: .render)
                .add(system: RepeatingAudioSystem(), priority: .render)
                .add(system: DisplaySystem(scene: scene), priority: .render)
                .add(system: XRayVisionSystem(), priority: .render)
    }
}
