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
        self.init()
        addSoundAction(play, withKey: key)
    }

    convenience init(fileNamed name: String, withKey key: String) {
        self.init()
        addSoundAction(SKAction.playSoundFileNamed(name, waitForCompletion: true), withKey: key)
    }

    func addSoundAction(_ action: SKAction, withKey key: String) {
        playlist[key] = action
    }

    func removeSoundAction(_ key: String) {
        keysToRemove.append(key)
    }
}


final class RepeatingAudioComponent: Component {
    var sound: SKAction
    var key: String
    var state: RepeatingSoundState = .notPlaying

    init(_ sound: SKAction, withKey key: String) {
        self.sound = sound
        self.key = key
        super.init()
    }
}
