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
        for (key, soundAction) in audioComponent.toPlay {
            scene.run(soundAction, withKey: key)
        }
        audioComponent.toPlay.removeAll()
        for soundAction in audioComponent.toRemove {
            scene.removeAction(forKey: soundAction)
        }
        audioComponent.toRemove.removeAll()
    }
    
	override public func removeFromEngine(engine: Engine) {
        scene = nil
    }
}



