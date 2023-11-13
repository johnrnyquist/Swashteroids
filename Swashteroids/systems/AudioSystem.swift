import SpriteKit
import Swash


class AudioSystem: ListIteratingSystem {
    var scene: SKScene!

    init(scene: SKScene) {
        self.scene = scene
        super.init(nodeClass: AudioNode.self)
        nodeUpdateFunction = updateNode
    }

    private func updateNode(node: Node, time: TimeInterval) {
        guard let audioComponent = node[AudioComponent.self]
        else { return }
        for (key, soundAction) in audioComponent.toPlay {
            scene.run(soundAction, withKey: key)
        }
        audioComponent.toPlay.removeAll()
        for soundAction in audioComponent.toRemove {
            scene.removeAction(forKey: soundAction)
        }
        audioComponent.toRemove.removeAll()
    }
}



