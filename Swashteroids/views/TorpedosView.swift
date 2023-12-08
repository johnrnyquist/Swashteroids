import SpriteKit
import Swash

// GunSupplierView
class PlasmaTorpedoesPowerUpView: SwashteroidsSpriteNode, Animatable {
    var time: TimeInterval = 0
    var dir = -1.0

    func animate(_ time: TimeInterval) {
        self.time += time
        if self.time > 1 {
            self.time = 0
            dir = dir == 1.0 ? -1.0 : 1.0
        }
//        alpha += Double(dir * time / 2)
//		xScale += Double(dir * time / 10)
//		yScale += Double(dir * time / 10)
    }
}
