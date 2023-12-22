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

protocol ScaleManaging {
    var SCALE_FACTOR: CGFloat { get }
}

class ScaleManager: ScaleManaging {
    static let shared = ScaleManager()
    private(set) var SCALE_FACTOR: CGFloat

    private init() {
        let designWidth = 1024.0
        let designHeight = 768.0
        SCALE_FACTOR = min(min(UIScreen.main.bounds.size.width / designWidth, 1.0),
                           min(UIScreen.main.bounds.size.height / designHeight, 1.0))
    }
}