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

protocol GameStateObserver: AnyObject {
    func onGameStateChange(state: GameScreen)
}

final class TransitionAppStateSystem: ListIteratingSystem {
    private let startTransition: StartUseCase?
    private let playingTransition: PlayingUseCase?
    private let gameOverTransition: GameOverUseCase?
    private let tutorialTransition: TutorialUseCase?
    weak var gamepadManager: GameStateObserver?

    init(
        startTransition: StartUseCase,
        playingTransition: PlayingUseCase,
        gameOverTransition: GameOverUseCase,
        tutorialTransition: TutorialUseCase
    ) {
        self.startTransition = startTransition
        self.gameOverTransition = gameOverTransition
        self.playingTransition = playingTransition
        self.tutorialTransition = tutorialTransition
        super.init(nodeClass: TransitionAppStateNode.self)
        nodeUpdateFunction = updateNode
    }

    func updateNode(node: Node, time: TimeInterval) {
        guard let transitionComponent = node[ChangeGameStateComponent.self],
              let appStateComponent = node[GameStateComponent.self]
        else { return }
        switch transitionComponent.from {
            case .start:
                startTransition?.fromStartScreen()
            case .gameOver:
                gameOverTransition?.fromGameOverScreen()
            case .playing:
                playingTransition?.fromPlayingScreen()
            case .tutorial:
                tutorialTransition?.fromTutorialScreen()
        }
        appStateComponent.gameScreen = transitionComponent.to
        gamepadManager?.onGameStateChange(state: appStateComponent.gameScreen)  //HACK
        switch transitionComponent.to {
            case .start:
                startTransition?.toStartScreen()
            case .gameOver:
                gameOverTransition?.toGameOverScreen()
            case .playing:
                appStateComponent.timePlayed = 0.0
                playingTransition?.toPlayingScreen(appStateComponent: appStateComponent)
            case .tutorial:
                tutorialTransition?.toTutorialScreen()
        }
        node.entity?.remove(componentClass: ChangeGameStateComponent.self)
    }
}

