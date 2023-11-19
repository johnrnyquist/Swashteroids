import Foundation
import Swash


final class DeathThroesComponent: Component {
    var countdown: TimeInterval

    init(countdown: TimeInterval) {
        self.countdown = countdown
        super.init()
    }
}
