import Swash

class ShipNode: Node {
    required init() {
        super.init()
        components = [
            PositionComponent.name: nil_component,
            ShipComponent.name: nil_component,
        ]
    }
}
