import Swash

final class WaitForStartNode: Node {
    required init() {
        super.init()
        components = [
            WaitForStartComponent.name: nil_component,
			DisplayComponent.name: nil_component,
            InputComponent.name: nil_component
        ]
    }
}
