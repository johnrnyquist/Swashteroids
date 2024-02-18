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
    static let shared = AllSoundsComponent() //HACK I'm doing this to cheat


    var soundActions: [String: SKAction] = [:]
    
    private override init() {
        super.init()
        preloadSounds()
    }

    private func preloadSounds() {
        // Preload the sound effects
        SoundFileNames.allCases.forEach { [weak self] soundFile in
            let soundAction = SKAction.playSoundFileNamed(soundFile.rawValue, waitForCompletion: false)
            self?.soundActions[soundFile.rawValue] = soundAction
        }
    }
}
