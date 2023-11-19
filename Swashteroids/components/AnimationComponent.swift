import Foundation
import Swash


final class AnimationComponent: Component {
    var animation: Animatable

    init(animation: Animatable) {
        self.animation = animation
        super.init()
    }
}

protocol Animatable {
    func animate(_ time: TimeInterval)
}

