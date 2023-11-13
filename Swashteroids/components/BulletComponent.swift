import Foundation
import Swash

class BulletComponent: Component {
    var lifeRemaining: TimeInterval = 0.0

    init(lifeRemaining: TimeInterval) {
        self.lifeRemaining = lifeRemaining
        super.init()
    }
}
