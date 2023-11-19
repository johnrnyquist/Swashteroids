import Foundation
import Swash

final class BulletComponent: Component {
    var lifeRemaining: TimeInterval = 0.0

    init(lifeRemaining: TimeInterval) {
        self.lifeRemaining = lifeRemaining
        super.init()
    }
}
