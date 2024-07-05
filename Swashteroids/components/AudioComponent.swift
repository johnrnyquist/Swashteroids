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
    var sound: Sound?

    init(key: String, fileName fullFilename: String) {
        self.key = key
        self.fileName = fullFilename
        let components = fullFilename.components(separatedBy: ".")
        if components.count == 2, let name = components.first, let ext = components.last {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                self.sound = Sound(url: url)
            } else {
                print("File `\(name)` not found.")
            }
        }
        super.init()
    }
}
