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

/// Used by the flip button and in the FlipSystem.
final class FlipComponent: Component {
    /// If something is just a flag that I use frequently, I make it a shared instance. 
    static let shared = FlipComponent()
    public var flipCount = 0

    private override init() {}
}

