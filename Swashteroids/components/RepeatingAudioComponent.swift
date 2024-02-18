//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import Swash
import SpriteKit

final class RepeatingAudioComponent: Component {
    var state: RepeatingSoundState = .notPlaying
    weak var sound: SKAudioNode?

    init(sound: SKAudioNode) {
        self.sound = sound
        self.sound?.autoplayLooped = true
        super.init()
    }
}

