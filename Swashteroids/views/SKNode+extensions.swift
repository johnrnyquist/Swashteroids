import SpriteKit
import Swash


extension SKNode {
    var x: Double {
        get { position.x }
        set { position = CGPoint(x: newValue, y: y) }
    }
    var y: Double {
        get { position.y }
        set { position = CGPoint(x: x, y: newValue) }
    }
}
