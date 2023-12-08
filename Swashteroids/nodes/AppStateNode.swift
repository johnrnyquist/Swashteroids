import Swash

final class AppStateNode: Node {
    required init() {
        super.init()
        components = [
            AppStateComponent.name: nil_component,
        ]
    }
}
