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

/// Used by the thrust button and in the ThrustSystem.
final class LeftComponent: Component {
    /// If something is just a flag that I use frequently, I make it a shared instance. 
    static let shared = LeftComponent()
    let amount = 0.0175

    private override init() {}
}
