import Swash

final class ShipEngineNode: Node {
    required init() {
        super.init()
        components = [
            DisplayComponent.name: nil_component,
            WarpDriveComponent.name: nil_component,
        ]
    }
}
