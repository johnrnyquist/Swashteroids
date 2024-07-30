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

enum PauseAlertAction {
    case resume
    case home
    case showSettings
    case hideSettings
    case showPauseAlert
    case none
}

final class AlertPresentingComponent: Component {
    var action: PauseAlertAction

    init(action: PauseAlertAction) {
        self.action = action
    }
}

final class AlertPresentingNode: Node {
    required init() {
        super.init()
        components = [
            AlertPresentingComponent.name: nil,
        ]
    }
}

final class AlertPresentingSystem: ListIteratingSystem {
    var alertPresenting: PauseAlertPresenting

    init(alertPresenting: PauseAlertPresenting) {
        self.alertPresenting = alertPresenting
        super.init(nodeClass: AlertPresentingNode.self)
        nodeUpdateFunction = updateNode
    }

    func updateNode(node: Node, time: TimeInterval) {
        guard let alertComponent = node[AlertPresentingComponent.self],
              let entity = node.entity
        else { return }
        switch alertComponent.action {
            case .showPauseAlert:
                entity.remove(componentClass: AlertPresentingComponent.self)
                alertComponent.action = .none
                alertPresenting.showPauseAlert()

            case .home:
                entity.remove(componentClass: AlertPresentingComponent.self)
                alertComponent.action = .none
                alertPresenting.home()

            case .resume:
                entity.remove(componentClass: AlertPresentingComponent.self)
                alertComponent.action = .none
                alertPresenting.resume()

            case .showSettings:
                alertComponent.action = .none
                alertPresenting.showSettings()

            case .hideSettings:
                alertComponent.action = .none
                alertPresenting.hideSettings()

            case .none:
                break
        }
    }
}
