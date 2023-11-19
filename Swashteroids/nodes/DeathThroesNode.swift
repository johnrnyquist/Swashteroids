import Swash

final class DeathThroesNode: Node {
    required init() {
        super.init()
        components = [
            DeathThroesComponent.name: nil_component,
        ]
    }
}

