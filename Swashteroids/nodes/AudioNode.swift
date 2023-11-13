import Swash

class AudioNode: Node {
    required init() {
        super.init()
        components = [
            AudioComponent.name: nil_component,
        ]
    }
}
