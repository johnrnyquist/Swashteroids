//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import Swash

/// Used by aliens to indicate that they are firing.
final class AlienFiringComponent: Component {
    static let shared = AlienFiringComponent()

    private override init() {}
}

/// Any entity with this component can be shot at by the aliens.
final class ShootableComponent: Component {
    static let shared = ShootableComponent()

    private override init() {}
}

/// Any entity with this component can be targeted by an alien worker (like an asteroid, a treasure, or the player).
final class AlienWorkerTargetComponent: Component {
    static let shared = AlienWorkerTargetComponent()

    private override init() {}
}