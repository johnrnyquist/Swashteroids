import Swash

//_TODO: This class needs to be reworked_
class MotionControlsComponent: Component {
    var left: UInt32 = 1
    var right: UInt32 = 2
    var accelerate: UInt32 = 4
    var accelerationRate: Double = 0
    var rotationRate: Double = 0

    init(left: UInt32, right: UInt32, accelerate: UInt32, accelerationRate: Double, rotationRate: Double) {
        self.left = left
        self.right = right
        self.accelerate = accelerate
        self.accelerationRate = accelerationRate
        self.rotationRate = rotationRate
    }
}
