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

final class AudioSystem: ListIteratingSystem {
    private weak var scene: SKScene!

    init(scene: SKScene) {
        self.scene = scene
        super.init(nodeClass: AudioNode.self)
        nodeUpdateFunction = updateNode
    }

    func updateNode(node: Node, time: TimeInterval) {
        guard let audioComponent = node[AudioComponent.self]
        else { return }
        for (soundKey, soundAction) in audioComponent.playlist {
            if scene.action(forKey: soundKey) != nil {
                continue // I never hit this, but it's here just in case
            }
            scene.run(soundAction, withKey: soundKey)
        }
        audioComponent.clearPlaylist()
        node.entity?.remove(componentClass: AudioComponent.self)
    }

    override public func removeFromEngine(engine: Engine) {
        scene = nil
    }
}




