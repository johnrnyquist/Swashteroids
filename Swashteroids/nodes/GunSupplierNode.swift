import Swash

class GunSupplierNode: Node {
    required init() {
        super.init()
        components = [
            CollisionComponent.name: nil_component,
            PositionComponent.name: nil_component,
            GunSupplierComponent.name: nil_component,
            DisplayComponent.name: nil_component,
        ]
    }
}
