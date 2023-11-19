import Swash

final class GameNode: Node {
    required init() {
        super.init()
        components = [
            GameStateComponent.name: nil_component,
        ]
    }
}
