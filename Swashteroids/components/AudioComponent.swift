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

/// Entities with this component will play this sounds in its playlist immediately from the AudioSystem.
final class AudioComponent: Component {
    private(set) var playlist: [String: SKAction] = [:]

    init(fileNamed: String, actionKey: String) {
        playlist[actionKey] = AllSoundsComponent.shared.soundActions[fileNamed]!
    }

    /// If you want to run more than one sound with this component, add the next sound with this method.
    func addSoundAction(fileNamed: String, actionKey: String) {
        playlist[actionKey] = AllSoundsComponent.shared.soundActions[fileNamed]!
    }

    func clearPlaylist() {
        playlist.removeAll()
    }
}
