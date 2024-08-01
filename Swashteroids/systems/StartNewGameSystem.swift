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

class StartNewGameComponent: Component {}

class StartNewGameNode: Node {
    required init() {
        super.init()
        components = [
            StartNewGameComponent.name: nil
        ]
    }
}

class StartNewGameSystem: ListIteratingSystem {
    weak var alertPresenter: PauseAlertPresenting? //HACK

    init(alertPresenter: PauseAlertPresenting) {
        self.alertPresenter = alertPresenter
        super.init(nodeClass: StartNewGameNode.self)
        nodeUpdateFunction = update
    }

    private func update(node: Node, deltaTime: TimeInterval) {
        alertPresenter?.home()
    }
}