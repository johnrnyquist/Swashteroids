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

/// Used to indicate the application of thrust. 
/// Per the ThrustNode, you need a ImpulseDriveComponent to apply thrust.
final class ApplyThrustComponent: Component {
/// If something is just a flag that I use frequently, I make it a shared instance. 
    static let shared = ApplyThrustComponent()

    private override init() {}
}

