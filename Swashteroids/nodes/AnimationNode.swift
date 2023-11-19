import Swash

final class AnimationNode: Node {
    required init() {
        super.init()
        components = [
            AnimationComponent.name: nil_component,
        ]
    }
}
