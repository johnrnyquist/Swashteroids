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
                print("Already playing \(soundKey)")
                continue
            }
            print("Playing \(soundKey)")
            scene.run(soundAction, withKey: soundKey)
        }
        audioComponent.playlist.removeAll()
        for soundKey in audioComponent.keysToRemove {
            print("Removing \(soundKey)")
            scene.removeAction(forKey: soundKey)
        }
    }

    override public func removeFromEngine(engine: Engine) {
        scene = nil
    }
}

final class RepeatingAudioSystem: ListIteratingSystem {
    private weak var scene: SKScene!

    init(scene: SKScene) {
        self.scene = scene
        super.init(nodeClass: RepeatingAudioNode.self)
        nodeUpdateFunction = updateNode
    }

    func updateNode(node: Node, time: TimeInterval) {
        guard let audio = node[RepeatingAudioComponent.self]
        else { return }
        switch audio.state {
            case .shouldBegin:
                if scene.action(forKey: audio.key) != nil {
                    audio.state = .playing
                } else {
                    let repeatForever = SKAction.repeatForever(audio.sound)
                    scene.run(repeatForever, withKey: audio.key)
                    audio.state = .playing
                }
            case .shouldStop:
                scene.removeAction(forKey: audio.key)
            case .notPlaying, .playing:
                break
        }
    }

    override public func removeFromEngine(engine: Engine) {
        scene = nil
    }
}



