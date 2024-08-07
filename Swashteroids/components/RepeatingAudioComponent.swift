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
import SwiftySound

final class RepeatingAudioComponent: Component {
    var state: RepeatingSoundState = .notPlaying
    var sound: Sound?
    let asset: AssetAudio

    init(asset: AssetAudio) {
        self.asset = asset
        let components = asset.fileName.components(separatedBy: ".")
        if components.count == 2,
           let name = components.first,
           let ext = components.last {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                sound = Sound(url: url)
            } else {
                print("FILE `\(name)` NOT FOUND.")
            }
        }
        super.init()
    }
}

