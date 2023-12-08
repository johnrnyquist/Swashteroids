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
    var toPlay: [String: SKAction] = [:]
    var toRemove: [String] = []

    override init() {
        super.init()
    }

    convenience init(_ play: String) {
        self.init()
        addSoundAction(SKAction.playSoundFileNamed(play, waitForCompletion: true), withKey: play)
    }

    func addSoundAction(_ action: SKAction, withKey: String) {
        toPlay[withKey] = action
    }

    func removeSoundAction(_ action: String) {
        toRemove.append(action)
    }
}
