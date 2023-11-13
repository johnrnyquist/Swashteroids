import SpriteKit
import Swash


class GunSupplierView: SKSpriteNode, Animatable {
    var time: TimeInterval = 0
    var dir = -1.0

    func animate(_ time: TimeInterval) {
        self.time += time
        if self.time > 1 {
            self.time = 0
            dir = dir == 1.0 ? -1.0 : 1.0
        }
        alpha += CGFloat(dir * time / 2)
    }
}
