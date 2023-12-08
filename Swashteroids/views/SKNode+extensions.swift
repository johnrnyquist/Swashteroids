//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import SpriteKit

extension SKNode {
    var x: Double {
        get { position.x }
        set { position = CGPoint(x: newValue, y: y) }
    }
    var y: Double {
        get { position.y }
        set { position = CGPoint(x: x, y: newValue) }
    }
}
