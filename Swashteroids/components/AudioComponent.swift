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
    private(set) var playlist: [String: SKAction] = [:]
    private(set) var keysToRemove: [String] = []

    override init() {
        super.init()
    }

    convenience init(fileNamed name: String, withKey key: String) {
        self.init()
        playlist[key] = AllSoundsComponent.shared.soundActions[name]! //HACK
    }

    func addSoundAction(_ action: String, withKey key: String) {
        playlist[key] = AllSoundsComponent.shared.soundActions[action]! //HACK
    }

    func removeSoundAction(_ key: String) {
        keysToRemove.append(key)
    }

    func clearPlaylist() {
        playlist.removeAll()
    }
}
