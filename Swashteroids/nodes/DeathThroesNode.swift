import Swash

class DeathThroesNode: Node {
    required init() {
        super.init()
        components = [
            DeathThroesComponent.name: nil_component,
        ]
    }
}

