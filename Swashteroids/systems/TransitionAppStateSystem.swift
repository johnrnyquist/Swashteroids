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
    weak var transition: Transition?

    init(transition: Transition) {
        self.transition = transition
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
                transition?.fromStartScreen()
            case .gameOver:
                transition?.fromGameOverScreen()
            case .playing:
                transition?.fromPlayingScreen()
            case .infoButtons:
                transition?.fromButtonsInfoScreen()
                appStateComponent.shipControlsState = .showingButtons
            case .infoNoButtons:
                transition?.fromNoButtonsInfoScreen()
                appStateComponent.shipControlsState = .hidingButtons
        }
        appStateComponent.appState = transitionComponent.to
        switch transitionComponent.to {
            case .initial:
                break
            case .start:
                transition?.toStartScreen()
            case .gameOver:
                transition?.toGameOverScreen()
            case .playing:
                appStateComponent.timePlayed = 0.0
                transition?.toPlayingScreen(appStateComponent: appStateComponent)
            case .infoButtons:
                transition?.toButtonsInfoScreen()
            case .infoNoButtons:
                transition?.toNoButtonsInfoScreen()
        }
        node.entity?.remove(componentClass: TransitionAppStateComponent.self)
    }
}
