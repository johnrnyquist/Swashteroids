import Swash

class ShipEngineNode: Node {
    required init() {
        super.init()
        components = [
            DisplayComponent.name: nil_component,
            EngineComponent.name: nil_component,
        ]
    }
}
