import Swash

final class GunSupplierNode: Node {
    required init() {
        super.init()
        components = [
            CollisionComponent.name: nil_component,
            PositionComponent.name: nil_component,
            GunPowerUpComponent.name: nil_component,
            DisplayComponent.name: nil_component,
        ]
    }
}
