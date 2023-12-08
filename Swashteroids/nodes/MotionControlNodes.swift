import Swash

final class FlipNode: Node {
    required init() {
        super.init()
        components = [
            PositionComponent.name: nil_component,
            FlipComponent.name: nil_component,
        ]
    }
}

final class LeftNode: Node {
    required init() {
        super.init()
        components = [
            PositionComponent.name: nil_component,
            MotionControlsComponent.name: nil_component,
            LeftComponent.name: nil_component,
        ]
    }
}

final class RightNode: Node {
    required init() {
        super.init()
        components = [
            PositionComponent.name: nil_component,
            MotionControlsComponent.name: nil_component,
            RightComponent.name: nil_component,
        ]
    }
}

final class ThrustNode: Node {
    required init() {
        super.init()
        components = [
            PositionComponent.name: nil_component,
            ThrustComponent.name: nil_component,
            MotionComponent.name: nil_component,
            MotionControlsComponent.name: nil_component,
            WarpDriveComponent.name: nil_component,
            AudioComponent.name: nil_component,
        ]
    }
}
