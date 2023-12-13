//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//
//
// Created by John Nyquist on 12/3/23.
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
              let appStateComponent = node[AppStateComponent.self] else { return }
        if let from = transitionComponent.from {
            switch from {
                case .initialize:
                    break
                case .start:
                    transition?.fromStart()
                case .gameOver:
                    transition?.fromGameOverScreen()
                    break
                case .playing:
                    transition?.fromPlayingScreen()
                    break
                case .infoButtons:
                    transition?.fromButtonsInfoScreen()
                    appStateComponent.shipControlsState = .showingButtons
                case .infoNoButtons:
                    transition?.fromNoButtonsInfoScreen()
                    appStateComponent.shipControlsState = .hidingButtons
            }
        }
        appStateComponent.appState = transitionComponent.to
        switch transitionComponent.to {
            case .initialize:
                transition?.toStartScreen()
            case .start:
                transition?.toStartScreen()
            case .gameOver:
                transition?.toGameOverScreen()
                break
            case .playing:
                if transitionComponent.from == .infoNoButtons {
                    transition?.toPlayingScreen(with: .hidingButtons)
                } else if transitionComponent.from == .infoButtons {
                    transition?.toPlayingScreen(with: .showingButtons)
                }
            case .infoButtons:
                transition?.toButtonsInfoScreen()
            case .infoNoButtons:
                transition?.toNoButtonsInfoScreen()
        }
        node.entity?.remove(componentClass: TransitionAppStateComponent.self)
    }
}
