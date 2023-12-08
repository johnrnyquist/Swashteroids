import Swash

final class HudNode: Node {
    required init() {
        super.init()
        components = [
            AppStateComponent.name: nil_component,
            HudComponent.name: nil_component,
        ]
    }
}
