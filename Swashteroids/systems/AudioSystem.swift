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

protocol SoundPlaying: AnyObject {
    func action(forKey: String) -> SKAction?
    func run(_ action: SKAction, withKey: String)
}

final class AudioSystem: ListIteratingSystem {
    private weak var soundPlayer: SoundPlaying?

    init(soundPlayer: SoundPlaying) {
        self.soundPlayer = soundPlayer
        super.init(nodeClass: AudioNode.self)
        nodeUpdateFunction = updateNode
    }

    func updateNode(node: Node, time: TimeInterval) {
        guard let audioComponent = node[AudioComponent.self]
        else { return }
        for (soundKey, soundAction) in audioComponent.playlist {
            if let _ = soundPlayer?.action(forKey: soundKey) {
                continue // I never hit this, but it's here just in case
            }
            soundPlayer?.run(soundAction, withKey: soundKey)
        }
        audioComponent.clearPlaylist()
        node.entity?.remove(componentClass: AudioComponent.self)
    }
}




