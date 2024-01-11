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
import Foundation

/// Holds the jump coordinates.
final class DoHyperspaceJumpComponent: Component {
    let x: Double
    let y: Double

	init(x: Double? = nil, y: Double? = nil, size: CGSize ) {
        if let x {
            self.x = x
        } else {
			self.x = Double.random(in: 0...size.width)
        }
        if let y {
            self.y = y
        } else {
			self.y = Double.random(in: 0...size.height)
        }
    }
}

