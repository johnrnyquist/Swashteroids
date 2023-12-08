import Swash

final class StartNode: Node {
    required init() {
        super.init()
        components = [
            StartComponent.name: nil_component,
			DisplayComponent.name: nil_component,
            InputComponent.name: nil_component
        ]
    }
}
