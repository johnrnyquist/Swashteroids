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

class AllSoundsComponent: Component {
    static let shared = AllSoundsComponent() //HACK: I'm doing this to cheat
    
    var soundActions: [String: SKAction] = [:]

    private override init() {
        super.init()
        preloadSounds()
    }

    private func preloadSounds() {
        let soundFiles = [
            "bangLarge.wav",
            "bangMedium.wav",
            "bangSmall.wav",
            "beat1.wav",
            "beat2.wav",
            "extraShip.wav",
            "fire.wav",
            "saucerBig.wav",
            "saucerSmall.wav",
            "thrust.wav",
            "toggle.wav",
        ]
        // Preload the sound effects
        for soundFile in soundFiles {
            let soundAction = SKAction.playSoundFileNamed(soundFile, waitForCompletion: false)
            soundActions[soundFile] = soundAction
        }
    }
}
