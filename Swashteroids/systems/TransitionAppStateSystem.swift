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

final class TransitionAppStateSystem: ListIteratingSystem {
    private let startTransition: StartUseCase?
    private let infoViewsTransition: InfoViewsUseCase?
    private let playingTransition: PlayingUseCase?
    private let gameOverTransition: GameOverUseCase?

    init(
        startTransition: StartUseCase,
        infoViewsTransition: InfoViewsUseCase,
        playingTransition: PlayingUseCase,
        gameOverTransition: GameOverUseCase
    ) {
        self.startTransition = startTransition
        self.gameOverTransition = gameOverTransition
        self.infoViewsTransition = infoViewsTransition
        self.playingTransition = playingTransition
        super.init(nodeClass: TransitionAppStateNode.self)
        nodeUpdateFunction = updateNode
    }

    func updateNode(node: Node, time: TimeInterval) {
        guard let transitionComponent = node[TransitionAppStateComponent.self],
              let appStateComponent = node[AppStateComponent.self]
        else { return }
        switch transitionComponent.from {
        case .initial:
            break
        case .start:
            startTransition?.fromStartScreen()
        case .gameOver:
            gameOverTransition?.fromGameOverScreen()
        case .playing:
            playingTransition?.fromPlayingScreen()
        case .infoButtons:
            infoViewsTransition?.fromButtonsInfoScreen()
            appStateComponent.shipControlsState = .showingButtons
        case .infoNoButtons:
            infoViewsTransition?.fromNoButtonsInfoScreen()
            appStateComponent.shipControlsState = .hidingButtons
        }
        appStateComponent.appState = transitionComponent.to
        switch transitionComponent.to {
        case .initial:
            break
        case .start:
            startTransition?.toStartScreen()
        case .gameOver:
            gameOverTransition?.toGameOverScreen()
        case .playing:
            appStateComponent.timePlayed = 0.0
            playingTransition?.toPlayingScreen(appStateComponent: appStateComponent)
        case .infoButtons:
            infoViewsTransition?.toButtonsInfoScreen()
        case .infoNoButtons:
            infoViewsTransition?.toNoButtonsInfoScreen()
        }
        node.entity?.remove(componentClass: TransitionAppStateComponent.self)
    }
}
