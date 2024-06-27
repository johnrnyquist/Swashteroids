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

final class TimePlayedSystem: ListIteratingSystem {
    init() {
        super.init(nodeClass: TimePlayedNode.self)
        nodeUpdateFunction = updateNode
    }

    private func updateNode(node: Node, time: TimeInterval) {
        guard let _ = node[TimePlayedComponent.self],
              let stateComponent = node[SwashteroidsStateComponent.self],
              stateComponent.swashteroidsState == .playing
        else { return }
        stateComponent.timePlayed += time
    }
}

//    This is acting soley as a flag at the moment.
final class TimePlayedComponent: Component {
//    For now I'm keeping this data in the AppStateComponent for convenience.
//    var timePlayed: TimeInterval = 0
}

final class TimePlayedNode: Node {
    required init() {
        super.init()
        components = [
            TimePlayedComponent.name: nil_component,
            SwashteroidsStateComponent.name: nil_component,
        ]
    }
}
