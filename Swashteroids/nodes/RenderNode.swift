import Swash

class RenderNode: Node {
    required init() {
        super.init()
        components = [
            DisplayComponent.name: nil_component,
            PositionComponent.name: nil_component,
        ]
    }
}
