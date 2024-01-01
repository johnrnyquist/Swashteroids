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
import Swash


final class AnimationComponent: Component {
    var animation: Animating

    init(animation: Animating) {
        self.animation = animation
        super.init()
    }
}

protocol Animating {
    func animate(_ time: TimeInterval)
}

