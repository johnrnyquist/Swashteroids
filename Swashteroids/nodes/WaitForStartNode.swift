import Swash

class WaitForStartNode: Node {
    required init() {
        super.init()
        components = [
            WaitForStartComponent.name: nil_component,
        ]
    }
}
