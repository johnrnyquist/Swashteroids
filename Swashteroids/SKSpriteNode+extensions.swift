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

extension SKSpriteNode {
    var width: CGFloat { size.width }
    var height: CGFloat { size.height }
    var scale: CGFloat {
        get { xScale }
        set {
            xScale = newValue
            yScale = newValue
        }
    }
}
