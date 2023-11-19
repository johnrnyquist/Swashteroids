import Swash

final class MotionControlsNode: Node {
    required init() {
        super.init()
        components = [
            MotionControlsComponent.name: nil_component,
            MotionComponent.name: nil_component,
            PositionComponent.name: nil_component,
            WarpDriveComponent.name: nil_component,
            AudioComponent.name: nil_component,
            InputComponent.name: nil_component
        ]
    }
}
