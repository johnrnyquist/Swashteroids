import Foundation
import Swash


class DeathThroesComponent: Component {
    var countdown: TimeInterval

    init(countdown: TimeInterval) {
        self.countdown = countdown
        super.init()
    }
}
