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

class SystemsManager {
    private(set) var transitionAppStateSystem: TransitionAppStateSystem

    init(scene: GameScene,
         engine: Engine,
         creatorManager: CreatorsManager,
         alertPresenter: PauseAlertPresenting,
         touchManager: TouchManager) {
        let transition = PlayingTransition(
            hudCreator: creatorManager.hudCreator,
            toggleShipControlsCreator: creatorManager.toggleShipControlsCreator,
            shipControlQuadrantsCreator: creatorManager.shipControlQuadrantsCreator,
            shipButtonControlsCreator: creatorManager.shipButtonControlsCreator)
        let startTransition = StartTransition(engine: engine, startScreenCreator: creatorManager.startScreenCreator)
        let gameOverTransition = GameOverTransition(engine: engine, alert: alertPresenter)
        let infoViewsTransition = InfoViewsTransition(engine: engine)
        transitionAppStateSystem = TransitionAppStateSystem(startTransition: startTransition,
                                                            infoViewsTransition: infoViewsTransition,
                                                            playingTransition: transition,
                                                            gameOverTransition: gameOverTransition)
        engine
            // preupdate
                .add(system: TouchedButtonSystem(touchManager: touchManager), priority: .preUpdate)
                .add(system: TouchedQuadrantSystem(touchManager: touchManager), priority: .preUpdate)
                .add(system: AlertPresentingSystem(alertPresenting: alertPresenter), priority: .preUpdate)
                .add(system: HyperspaceJumpSystem(engine: engine), priority: .preUpdate)
                .add(system: FiringSystem(torpedoCreator: creatorManager.torpedoCreator), priority: .preUpdate)
                .add(system: FlipSystem(), priority: .preUpdate)
                .add(system: LeftSystem(), priority: .preUpdate)
                .add(system: RightSystem(), priority: .preUpdate)
                .add(system: ThrustSystem(), priority: .preUpdate)
                .add(system: TimePlayedSystem(), priority: .preUpdate)
                .add(system: GameplayManagerSystem(asteroidCreator: creatorManager.asteroidCreator,
                                                   alienCreator: creatorManager.alienCreator,
                                                   playerCreator: creatorManager.shipCreator,
                                                   scene: scene),
                     priority: .preUpdate)
                .add(system: GameOverSystem(), priority: .preUpdate)
                .add(system: ShipControlsSystem(toggleShipControlsCreator: creatorManager.toggleShipControlsCreator,
                                                shipControlQuadrantsCreator: creatorManager.shipControlQuadrantsCreator,
                                                shipButtonControlsCreator: creatorManager.shipButtonControlsCreator,
                                                startButtonsCreator: creatorManager.startScreenCreator),
                     priority: .update)
                .add(system: transitionAppStateSystem,
                     priority: .preUpdate)
                // update
                .add(system: CreateXRayPowerUpSystem(powerUpCreator: creatorManager.powerUpCreator), priority: .update)
                .add(system: AlienAppearancesSystem(alienCreator: creatorManager.alienCreator), priority: .update)
                .add(system: LifetimeSystem(), priority: .update)
                .add(system: ReactionTimeSystem(), priority: .update)
                .add(system: PickTargetSystem(), priority: .update)
                .add(system: MoveToTargetSystem(), priority: .update)
                .add(system: ExitScreenSystem(), priority: .update)
                .add(system: AlienFiringSystem(torpedoCreator: creatorManager.torpedoCreator, gameSize: scene.size),
                     priority: .update)
                .add(system: TorpedoAgeSystem(), priority: .update)
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
                // resolve collisions
                .add(system: CollisionSystem(shipCreator: creatorManager.shipCreator,
                                             asteroidCreator: creatorManager.asteroidCreator,
                                             shipButtonControlsCreator: creatorManager.shipButtonControlsCreator,
                                             size: scene.size),
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
