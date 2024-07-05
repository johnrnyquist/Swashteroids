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
    let name: String
    let fileName: String

    init(name: String, fileName: SoundFileName) {
        self.name = name
        self.fileName = fileName
        super.init()
    }
}
