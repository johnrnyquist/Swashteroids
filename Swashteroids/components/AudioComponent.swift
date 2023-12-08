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

final class AudioComponent: Component {
    var playlist: [String: SKAction] = [:]
    var keysToRemove: [String] = []

    override init() {
        super.init()
    }

    convenience init(_ play: SKAction, withKey key: String) {
        print("AudioComponent.init(\(key)")
        self.init()
        addSoundAction(play, withKey: key)
    }

    convenience init(fileNamed name: String, withKey key: String) {
        print("AudioComponent.init(\(name)")
        self.init()
        addSoundAction(SKAction.playSoundFileNamed(name, waitForCompletion: true), withKey: key)
    }

    func addSoundAction(_ action: SKAction, withKey key: String) {
        print("AudioComponent.addSoundAction(\(key))")
        playlist[key] = action
    }

    func removeSoundAction(_ key: String) {
        print("AudioComponent.removeSoundAction(\(key))")
        keysToRemove.append(key)
    }
}


final class RepeatingAudioComponent: Component {
    var sound: SKAction
    var key: String
    var state: RepeatingSoundState = .notPlaying

    init(_ play: SKAction, withKey key: String) {
        self.sound = play
        self.key = key
        super.init()
    }
}
