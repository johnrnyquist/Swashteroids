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
import SwiftySound

final class AudioComponent: Component {
    let fileName: String
    let key: String

    init(key: String, fileName fullFilename: String) {
        self.key = key
        self.fileName = fullFilename
        super.init()
    }
}
