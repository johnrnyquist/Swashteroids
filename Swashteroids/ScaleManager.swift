//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import UIKit

protocol ScaleManaging: AnyObject {
    var SCALE_FACTOR: CGFloat { get }
}

/// ScaleManager is a singleton that calculates the scale factor based on the screen size.
final class ScaleManager: ScaleManaging {
    /// The shared instance of the ScaleManager.
    static let shared: ScaleManaging = ScaleManager()
    /// The scale factor based on the screen size.
    var SCALE_FACTOR: CGFloat

    /// Initializes the ScaleManager with the screen size.
    private init(width: CGFloat = UIScreen.main.bounds.size.width,
                 height: CGFloat = UIScreen.main.bounds.size.height) {
        let designWidth = 1024.0
        let designHeight = 768.0
        SCALE_FACTOR = min(min(width / designWidth, 1.0),
                           min(height / designHeight, 1.0))
    }
}