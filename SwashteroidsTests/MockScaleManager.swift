//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import Foundation
@testable import Swashteroids

final class MockScaleManager: ScaleManaging {
    var SCALE_FACTOR: CGFloat { 1.0 }
}

final class MockScaleManager_halfSize: ScaleManaging {
    var SCALE_FACTOR: CGFloat { 0.5 }
}
