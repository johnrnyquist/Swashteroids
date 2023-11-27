import Swash

final class GameStateNode: Node {
    required init() {
        super.init()
        components = [
            GameStateComponent.name: nil_component,
        ]
    }
}
