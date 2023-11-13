import Swash

class MotionControlsNode: Node {
    required init() {
        super.init()
        components = [
            MotionControlsComponent.name: nil_component,
            MotionComponent.name: nil_component,
            PositionComponent.name: nil_component,
            EngineComponent.name: nil_component,
            AudioComponent.name: nil_component
        ]
    }
}
