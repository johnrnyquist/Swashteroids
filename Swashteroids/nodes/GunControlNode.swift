import Swash

// GunControlNode
// You need a Gun and the TriggerDown to fire
final class GunControlNode: Node {
    required init() {
        super.init()
        components = [
            MotionComponent.name: nil_component,
            PositionComponent.name: nil_component,
            GunComponent.name: nil_component,
            TriggerDownComponent.name: nil_component
        ]
    }
}

