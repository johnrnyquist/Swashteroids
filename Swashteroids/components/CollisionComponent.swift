import Swash

final class CollisionComponent: Component {
    var radius = 0.0

    init(radius: Double) {
        self.radius = radius
        super.init()
    }
}
