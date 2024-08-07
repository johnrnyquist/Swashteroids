//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import SpriteKit
import Swash
import SwiftySound

class AudioSystem: ListIteratingSystem {
    init() {
        super.init(nodeClass: AudioNode.self)
        nodeUpdateFunction = updateNode
    }

    func updateNode(node: Node, time: TimeInterval) {
        guard let audioComponent = node[AudioComponent.self]
        else { return }
        Sound.play(file: audioComponent.asset.fileName)
        node.entity?.remove(componentClass: AudioComponent.self)
    }
}




