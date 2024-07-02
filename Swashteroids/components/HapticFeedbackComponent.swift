//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import Foundation
import SpriteKit
import Swash

class HapticFeedbackComponent: Component {
    static let shared = HapticFeedbackComponent()
    private let generator = UIImpactFeedbackGenerator(style: .heavy)

    private override init() {}
    
    func hapticFeedback() {
            generator.impactOccurred()
    }
}
