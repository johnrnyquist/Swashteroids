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
    weak var creator: Creator?

    init(creator: Creator) {
        self.creator = creator
        super.init(nodeClass: TransitionAppStateNode.self)
        nodeUpdateFunction = updateNode
    }

    func updateNode(node: Node, time: TimeInterval) {
        guard let transition = node[TransitionAppStateComponent.self],
              let appStateComponent = node[AppStateComponent.self] else { return }
        if let from = transition.from {
            switch from {
                case .initialize:
                    break
                case .start:
                    creator?.transitionFromStart()
                case .gameOver:
                    creator?.transitionFromGameOverScreen()
                    break
                case .playing:
                    creator?.transitionFromPlayingScreen()
                    break
                case .infoButtons:
                    creator?.tranistionFromButtonsInfoScreen()
                    appStateComponent.shipControlsState = .showingButtons
                case .infoNoButtons:
                    creator?.transitionFromNoButtonsInfoScreen()
                    appStateComponent.shipControlsState = .hidingButtons
            }
        }
        appStateComponent.appState = transition.to
        switch transition.to {
            case .initialize:
                creator?.transitionToStartScreen()
            case .start:
                creator?.transitionToStartScreen()
            case .gameOver:
                creator?.transitionToGameOverScreen()
                break
            case .playing:
                if transition.from == .infoNoButtons {
                    creator?.transitionToPlayingScreen(with: .hidingButtons)
                } else if transition.from == .infoButtons {
                    creator?.transitionToPlayingScreen(with: .showingButtons)
                }
            case .infoButtons:
                creator?.transitionToButtonsInfoScreen()
            case .infoNoButtons:
                creator?.transitionToNoButtonsInfoScreen()
        }
        node.entity?.remove(componentClass: TransitionAppStateComponent.self)
    }
}
