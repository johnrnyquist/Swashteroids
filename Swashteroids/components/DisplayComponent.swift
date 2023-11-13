import SpriteKit
import Swash


class DisplayComponent: Component {
    var displayObject: SKNode?

    init(displayObject: SKNode) {
        self.displayObject = displayObject
    }
}
