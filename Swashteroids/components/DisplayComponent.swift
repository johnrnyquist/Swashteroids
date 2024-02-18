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
import Swash


final class DisplayComponent: Component {
    private(set) weak var sknode: SKNode?

    init(sknode: SKNode) {
        self.sknode = sknode
    }
    
    // There are several types that could be displayed, i.e. SKSpriteNode, SKShapeNode, SKLabelNode, etc 
    // so I chose the root type. A downside is down casting. Here are a couple computed properties.
    var sprite: SwashSpriteNode? { sknode as? SwashSpriteNode}
    var label: SKLabelNode? { sknode as? SKLabelNode}
}
