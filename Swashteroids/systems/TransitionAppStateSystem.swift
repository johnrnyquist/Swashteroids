//
// Created by John Nyquist on 12/3/23.
//

import Foundation
import Swash


enum AppState {
	case initialize
	case start
	case over
	case playing
	case infoButtons
	case infoNoButtons
}

final class TransitionAppStateSystem: ListIteratingSystem {
    weak var creator: Creator?

    init(creator: Creator) {
        self.creator = creator
        super.init(nodeClass: TransitionAppStateNode.self)
        nodeUpdateFunction = updateNode
    }

    func updateNode(node: Node, time: TimeInterval) {
		guard let transition = node[TransitionAppStateComponent.self],
			  let appState = node[AppStateComponent.self] else { return }

		if let from = transition.from {
            switch from {
                case .initialize:
                    break
                case .start:
                    creator?.tearDownStart()
                case .over:
                    break
                case .playing:
                    break
                case .infoButtons:
                    creator?.tearDownInfoButtons()
					appState.shipControlsState = .showingButtons
					creator?.engine.ship?.remove(componentClass: AccelerometerComponent.self)


                case .infoNoButtons:
                    creator?.tearDownInfoNoButtons()
					appState.shipControlsState = .hidingButtons
					creator?.engine.ship?.add(component: AccelerometerComponent())


            }
        }
        switch transition.to {
            case .initialize:
                creator?.setUpStart()
            case .start:
                creator?.setUpStart()
            case .over:
                break
            case .playing:
                if transition.from == .infoNoButtons {
                     creator?.setUpPlaying(with: .hidingButtons)
                } else if transition.from == .infoButtons {
                     creator?.setUpPlaying(with: .showingButtons)
                }
            case .infoButtons:
                creator?.setUpButtonsInfoView()
            case .infoNoButtons:
                creator?.setUpNoButtonsInfoView()
        }
        node.entity?.remove(componentClass: TransitionAppStateComponent.self)
    }
}

