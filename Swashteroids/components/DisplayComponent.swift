import SpriteKit
import Swash


final class DisplayComponent: Component {
    var displayObject: SKNode?

    init(displayObject: SKNode) {
        self.displayObject = displayObject
    }
}
