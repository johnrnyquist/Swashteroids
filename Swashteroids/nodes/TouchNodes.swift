import Swash

final class TouchableNode: Node {
    required init() {
        super.init()
        components = [
            TouchableComponent.name: nil_component,
            DisplayComponent.name: nil_component
        ]
    }
}
