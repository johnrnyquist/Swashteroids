import Swash

class HudNode: Node {
    required init() {
        super.init()
        components = [
            GameStateComponent.name: nil_component,
            HudComponent.name: nil_component,
        ]
    }
}
